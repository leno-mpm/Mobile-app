import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { identification } = await req.json();

    if (typeof identification !== "string" || !/^\d{10}$/.test(identification)) {
      return new Response(
        JSON.stringify({ error: "La cédula debe tener 10 dígitos numéricos" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const { data: profile, error: profileError } = await supabase
      .from("profiles")
      .select("id")
      .eq("identification", identification)
      .maybeSingle();

    if (profileError) throw profileError;

    const { data: accounts, error: accountsError } = await supabase
      .from("accounts")
      .select("id, account_number, account_type, balance")
      .eq("identification", identification);

    if (accountsError) throw accountsError;

    const { count: policiesCount, error: policiesError } = await supabase
      .from("policies")
      .select("id", { count: "exact", head: true })
      .eq("identification", identification);

    if (policiesError) throw policiesError;

    const hasProfile = profile !== null;
    const hasAnyProduct = (accounts?.length ?? 0) > 0 || (policiesCount ?? 0) > 0;

    return new Response(
      JSON.stringify({
        hasProfile,
        hasAnyProduct,
        accounts: (accounts ?? []).map((a) => ({
          id: a.id,
          accountNumber: a.account_number,
          accountType: a.account_type,
          balance: a.balance,
        })),
        policiesCount: policiesCount ?? 0,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (error) {
    console.error("check-identification error:", error);
    return new Response(
      JSON.stringify({ error: "No se pudo verificar la cédula" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
