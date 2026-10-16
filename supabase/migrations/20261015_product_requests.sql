-- Aplicar manualmente en el SQL Editor del proyecto de Supabase.
-- Aditivo: no toca las tablas/triggers/RLS existentes (handle_new_user,
-- politicas auth.uid() = user_id, etc.).
--
-- NOTA: ALTER COLUMN ... DROP NOT NULL y ADD CONSTRAINT no son idempotentes.
-- Si alguna linea puntual falla porque ya existe, se puede omitir esa linea
-- sin afectar al resto del script.

-- =====================================================================
-- 1. Permitir que existan productos antes de que exista un usuario
-- =====================================================================

ALTER TABLE public.accounts ALTER COLUMN user_id DROP NOT NULL;
ALTER TABLE public.accounts ADD COLUMN IF NOT EXISTS identification text;

ALTER TABLE public.policies ALTER COLUMN user_id DROP NOT NULL;
ALTER TABLE public.policies ADD COLUMN IF NOT EXISTS identification text;

ALTER TABLE public.accounts
  ADD CONSTRAINT accounts_owner_present
  CHECK (user_id IS NOT NULL OR identification IS NOT NULL);

ALTER TABLE public.policies
  ADD CONSTRAINT policies_owner_present
  CHECK (user_id IS NOT NULL OR identification IS NOT NULL);

ALTER TABLE public.policies
  ADD COLUMN IF NOT EXISTS source_account_id uuid
  REFERENCES public.accounts (id);

CREATE INDEX IF NOT EXISTS idx_accounts_identification ON public.accounts (identification);
CREATE INDEX IF NOT EXISTS idx_policies_identification ON public.policies (identification);
CREATE INDEX IF NOT EXISTS idx_profiles_identification ON public.profiles (identification);

-- =====================================================================
-- 2. Bloquear acceso directo de anon/authenticated a estas tablas.
--    Todo acceso no autenticado pasa por las Edge Functions (service role).
--    Las politicas RLS actuales (auth.uid() = user_id) siguen siendo
--    correctas porque para anon, auth.uid() es NULL y nunca iguala a un
--    user_id (ni siquiera ahora que user_id puede ser NULL tambien).
-- =====================================================================

REVOKE INSERT, UPDATE, DELETE ON public.accounts FROM anon, authenticated;
REVOKE INSERT, UPDATE, DELETE ON public.policies FROM anon, authenticated;
REVOKE SELECT ON public.profiles FROM anon;

-- =====================================================================
-- 3. Generacion de numeros de cuenta/poliza
-- =====================================================================

CREATE SEQUENCE IF NOT EXISTS public.account_number_seq START 1;
CREATE SEQUENCE IF NOT EXISTS public.policy_number_seq START 1;

-- 10 digitos: prefijo 1 = Ahorros, 2 = Corriente + 9 digitos de secuencia
CREATE OR REPLACE FUNCTION public.generate_account_number(p_account_type text)
RETURNS text LANGUAGE sql AS $$
  SELECT (CASE WHEN p_account_type = 'Ahorros' THEN '1' ELSE '2' END)
    || lpad(nextval('public.account_number_seq')::text, 9, '0');
$$;

-- POL-<año>-<6 digitos>, ej. POL-2026-000123
CREATE OR REPLACE FUNCTION public.generate_policy_number()
RETURNS text LANGUAGE sql AS $$
  SELECT 'POL-' || to_char(now(), 'YYYY') || '-'
    || lpad(nextval('public.policy_number_seq')::text, 6, '0');
$$;

REVOKE EXECUTE ON FUNCTION public.generate_account_number(text) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.generate_policy_number() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.generate_account_number(text) TO service_role;
GRANT EXECUTE ON FUNCTION public.generate_policy_number() TO service_role;

-- =====================================================================
-- 4. Vincular productos pendientes al crear el perfil (trigger separado
--    del handle_new_user existente, asi no hay que tocarlo ni verlo)
-- =====================================================================

CREATE OR REPLACE FUNCTION public.link_pending_products()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  UPDATE public.accounts SET user_id = NEW.id
   WHERE identification = NEW.identification AND user_id IS NULL;

  UPDATE public.policies SET user_id = NEW.id
   WHERE identification = NEW.identification AND user_id IS NULL;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_profile_created_link_products ON public.profiles;

CREATE TRIGGER on_profile_created_link_products
  AFTER INSERT ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.link_pending_products();

-- =====================================================================
-- 5. Permisos explicitos para service_role.
--    En este proyecto service_role no tenia GRANT de tabla sobre estas
--    tablas (solo bypassa RLS, pero RLS y GRANT son cosas distintas).
--    Sin esto, las Edge Functions fallan con "permission denied".
-- =====================================================================

GRANT SELECT, INSERT, UPDATE ON public.accounts TO service_role;
GRANT SELECT, INSERT, UPDATE ON public.policies TO service_role;
GRANT SELECT ON public.profiles TO service_role;
GRANT SELECT, INSERT ON public.transactions TO service_role;

GRANT USAGE, SELECT ON SEQUENCE public.account_number_seq TO service_role;
GRANT USAGE, SELECT ON SEQUENCE public.policy_number_seq TO service_role;

-- =====================================================================
-- 6. Debito atomico de saldo (evita condicion de carrera).
--    Antes, request-product/make-payment leian el balance y lo
--    actualizaban en dos pasos separados: si dos solicitudes para la
--    misma cuenta llegaban casi al mismo tiempo, una podia sobrescribir
--    el descuento de la otra. Esta funcion hace el chequeo+resta en
--    una sola instruccion UPDATE, atomica por fila en Postgres.
-- =====================================================================

CREATE OR REPLACE FUNCTION public.debit_account_balance(
  p_account_id uuid,
  p_amount numeric
)
RETURNS numeric
LANGUAGE plpgsql
AS $$
DECLARE
  v_new_balance numeric;
BEGIN
  UPDATE public.accounts
     SET balance = balance - p_amount
   WHERE id = p_account_id
     AND balance >= p_amount
  RETURNING balance INTO v_new_balance;

  IF v_new_balance IS NULL THEN
    RAISE EXCEPTION 'INSUFFICIENT_FUNDS';
  END IF;

  RETURN v_new_balance;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.debit_account_balance(uuid, numeric) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.debit_account_balance(uuid, numeric) TO service_role;
