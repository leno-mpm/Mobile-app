import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

// A diferencia de check-identification/request-product, esta función SÍ
// verifica el JWT (se despliega SIN --no-verify-jwt): solo un usuario
// autenticado puede pagar, y solo desde una cuenta que sea suya.
Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization");

    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: "No autenticado" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const { accountId, serviceName, amount } = await req.json();

    if (typeof accountId !== "string" || !accountId) {
      return new Response(
        JSON.stringify({ error: "Cuenta inválida" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    if (typeof serviceName !== "string" || !serviceName.trim()) {
      return new Response(
        JSON.stringify({ error: "Servicio inválido" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const parsedAmount = Number(amount);

    if (!Number.isFinite(parsedAmount) || parsedAmount <= 0) {
      return new Response(
        JSON.stringify({ error: "Ingresa un monto válido" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // Cliente con la sesión del usuario: solo para resolver quién es.
    const callerClient = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } },
    );

    const { data: userData, error: userError } = await callerClient.auth.getUser();

    if (userError || !userData.user) {
      return new Response(
        JSON.stringify({ error: "No autenticado" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const userId = userData.user.id;

    // Cliente con service role: para las escrituras reales.
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const { data: account, error: accountError } = await supabase
      .from("accounts")
      .select("id, balance, user_id")
      .eq("id", accountId)
      .maybeSingle();

    if (accountError) throw accountError;

    if (!account || account.user_id !== userId) {
      return new Response(
        JSON.stringify({ error: "Esa cuenta no te pertenece", code: "INVALID_ACCOUNT" }),
        { status: 403, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    if (parsedAmount > account.balance) {
      return new Response(
        JSON.stringify({ error: "Saldo insuficiente", code: "INSUFFICIENT_FUNDS" }),
        { status: 409, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // Débito atómico (chequeo + resta en una sola instrucción SQL),
    // para evitar que dos solicitudes casi simultáneas pisen el
    // descuento de la otra.
    const { data: newBalanceData, error: balanceError } = await supabase.rpc(
      "debit_account_balance",
      { p_account_id: accountId, p_amount: parsedAmount },
    );

    if (balanceError) {
      if (balanceError.message?.includes("INSUFFICIENT_FUNDS")) {
        return new Response(
          JSON.stringify({ error: "Saldo insuficiente", code: "INSUFFICIENT_FUNDS" }),
          { status: 409, headers: { ...corsHeaders, "Content-Type": "application/json" } },
        );
      }
      throw balanceError;
    }

    const newBalance = newBalanceData as number;

    const { error: transactionError } = await supabase.from("transactions").insert({
      account_id: accountId,
      user_id: userId,
      description: `Pago de ${serviceName}`,
      amount: parsedAmount,
      date: new Date().toISOString(),
      category: "Servicios",
      type: "egreso",
    });

    if (transactionError) throw transactionError;

    return new Response(
      JSON.stringify({ newBalance }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (error) {
    console.error("make-payment error:", error);
    return new Response(
      JSON.stringify({ error: "No se pudo procesar el pago" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
