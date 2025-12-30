## 2025-12-30 - [Missing Auth in Gemini Function]
**Vulnerability:** The `get-gemini-ephemeral-token` Supabase function was publicly accessible without any authentication, allowing anyone to generate Gemini tokens.
**Learning:** Even with Supabase API Gateway, Edge Functions dealing with sensitive 3rd party APIs must explicitly validate the user session using `supabase.auth.getUser()` to ensure only valid, logged-in users consume quotas.
**Prevention:** Always copy the auth verification pattern from `create-wallet-pass` for any new Edge Function that dispenses tokens or accesses private data.
