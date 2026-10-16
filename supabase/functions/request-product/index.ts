import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const ACCOUNT_TYPE_BY_PRODUCT: Record<string, string> = {
  ahorro: "Ahorros",
  corriente: "Corriente",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { identification, productType, sourceAccountId, amount, termDays } =
      await req.json();

    if (typeof identification !== "string" || !/^\d{10}$/.test(identification)) {
      return new Response(
        JSON.stringify({ error: "La cédula debe tener 10 dígitos numéricos" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    if (!["ahorro", "corriente", "poliza"].includes(productType)) {
      return new Response(
        JSON.stringify({ error: "Tipo de producto inválido" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    // Se busca el perfil ANTES de crear el producto: si la cédula ya
    // tiene usuario, el producto se vincula de una vez (user_id), en
    // vez de quedar con user_id null esperando un trigger que solo se
    // dispara al CREAR un perfil nuevo (no aplica si ya existía).
    const { data: existingProfile, error: existingProfileError } =
      await supabase
        .from("profiles")
        .select("id")
        .eq("identification", identification)
        .maybeSingle();

    if (existingProfileError) throw existingProfileError;

    const ownerUserId = existingProfile?.id ?? null;

    let productNumber: string;
    let createdAccountId: string | null = null;
    let usedSourceAccountId: string | null = null;

    if (productType === "ahorro" || productType === "corriente") {
      const dbAccountType = ACCOUNT_TYPE_BY_PRODUCT[productType];

      const { data: numberData, error: numberError } = await supabase
        .rpc("generate_account_number", { p_account_type: dbAccountType });

      if (numberError) throw numberError;
      productNumber = numberData as string;

      const { data: inserted, error: insertError } = await supabase
        .from("accounts")
        .insert({
          identification,
          account_number: productNumber,
          account_type: dbAccountType,
          balance: 0,
          currency: "USD",
          user_id: ownerUserId,
        })
        .select("id")
        .single();

      if (insertError) throw insertError;
      createdAccountId = inserted.id;
    } else {
      // productType === 'poliza'
      const { data: accounts, error: accountsError } = await supabase
        .from("accounts")
        .select("id, balance")
        .eq("identification", identification);

      if (accountsError) throw accountsError;

      if (!accounts || accounts.length === 0) {
        return new Response(
          JSON.stringify({
            error: "Primero debes solicitar una cuenta de ahorros o corriente",
            code: "NO_ACCOUNT",
          }),
          { status: 409, headers: { ...corsHeaders, "Content-Type": "application/json" } },
        );
      }

      let sourceAccount: { id: string; balance: number };

      if (accounts.length === 1) {
        sourceAccount = accounts[0];
      } else {
        const match = accounts.find((a) => a.id === sourceAccountId);

        if (!match) {
          return new Response(
            JSON.stringify({
              error: "Debes seleccionar una cuenta válida de la cédula",
              code: "SOURCE_ACCOUNT_REQUIRED",
            }),
            { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
          );
        }

        sourceAccount = match;
      }

      // Monto mínimo para invertir en una póliza (debe coincidir con
      // AppConstants.minPolicyAmount del lado Flutter).
      const MIN_POLICY_AMOUNT = 100;

      // La cuenta que financia la póliza debe tener al menos el
      // mínimo disponible.
      if (sourceAccount.balance < MIN_POLICY_AMOUNT) {
        return new Response(
          JSON.stringify({
            error: `La cuenta seleccionada no tiene al menos $${MIN_POLICY_AMOUNT} `
              + "disponibles para solicitar una póliza",
            code: "INSUFFICIENT_FUNDS",
          }),
          { status: 409, headers: { ...corsHeaders, "Content-Type": "application/json" } },
        );
      }

      // El monto a invertir y el plazo son obligatorios para póliza, y
      // el monto debe ser menor al saldo disponible de la cuenta (para
      // poder restarlo de ahí).
      const parsedAmount = Number(amount);
      const parsedTermDays = Number(termDays);

      if (!Number.isFinite(parsedAmount) || parsedAmount < MIN_POLICY_AMOUNT) {
        return new Response(
          JSON.stringify({
            error: `El monto mínimo para una póliza es $${MIN_POLICY_AMOUNT}`,
            code: "AMOUNT_TOO_LOW",
          }),
          { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
        );
      }

      if (parsedAmount >= sourceAccount.balance) {
        return new Response(
          JSON.stringify({
            error: "El monto debe ser menor al saldo disponible de tu cuenta",
            code: "AMOUNT_EXCEEDS_BALANCE",
          }),
          { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
        );
      }

      if (!Number.isFinite(parsedTermDays) || parsedTermDays < 30 || parsedTermDays > 1095) {
        return new Response(
          JSON.stringify({
            error: "El plazo debe estar entre 1 mes y 3 años",
            code: "INVALID_TERM",
          }),
          { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
        );
      }

      usedSourceAccountId = sourceAccount.id;

      const { data: numberData, error: numberError } = await supabase
        .rpc("generate_policy_number");

      if (numberError) throw numberError;
      productNumber = numberData as string;

      const startDate = new Date();
      const endDate = new Date(startDate);
      endDate.setDate(endDate.getDate() + parsedTermDays);

      const { error: insertError } = await supabase.from("policies").insert({
        identification,
        policy_number: productNumber,
        amount: parsedAmount,
        annual_interest_rate: 5,
        term_days: parsedTermDays,
        start_date: startDate.toISOString(),
        end_date: endDate.toISOString(),
        currency: "USD",
        status: "Activa",
        source_account_id: usedSourceAccountId,
        user_id: ownerUserId,
      });

      if (insertError) throw insertError;

      // Se debita el monto de la cuenta de origen de forma atómica
      // (chequeo + resta en una sola instrucción SQL), para evitar que
      // dos solicitudes casi simultáneas pisen el descuento de la otra.
      const { error: balanceError } = await supabase.rpc(
        "debit_account_balance",
        { p_account_id: sourceAccount.id, p_amount: parsedAmount },
      );

      if (balanceError) {
        if (balanceError.message?.includes("INSUFFICIENT_FUNDS")) {
          return new Response(
            JSON.stringify({
              error: "El monto debe ser menor al saldo disponible de tu cuenta",
              code: "AMOUNT_EXCEEDS_BALANCE",
            }),
            { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
          );
        }
        throw balanceError;
      }

      // Se registra el egreso en movimientos. Solo si ya existe un
      // usuario: sin perfil todavía nadie puede ver movimientos de
      // todas formas (requiere sesión autenticada).
      if (ownerUserId !== null) {
        const { error: transactionError } = await supabase
          .from("transactions")
          .insert({
            account_id: sourceAccount.id,
            user_id: ownerUserId,
            description: `Apertura de póliza ${productNumber}`,
            amount: parsedAmount,
            date: startDate.toISOString(),
            category: "Inversiones",
            type: "egreso",
          });

        if (transactionError) throw transactionError;
      }
    }

    return new Response(
      JSON.stringify({
        productNumber,
        productType,
        accountId: createdAccountId,
        sourceAccountId: usedSourceAccountId,
        hasProfile: ownerUserId !== null,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (error) {
    console.error("request-product error:", error);
    return new Response(
      JSON.stringify({ error: "No se pudo completar la solicitud del producto" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
