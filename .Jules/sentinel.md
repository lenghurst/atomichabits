## 2024-05-23 - [CRITICAL] Unsecured Edge Function
**Vulnerability:** The `get-gemini-ephemeral-token` Supabase Edge Function was generating tokens without validating the Supabase JWT.
**Learning:** Edge Functions are public endpoints by default. Even if they are "internal" to the app, they must explicitly validate the `Authorization` header using `supabase.auth.getUser()`.
**Prevention:** Always verify the user session at the start of any Edge Function that performs sensitive operations or incurs costs. Use the `createClient` with the `Authorization` header passed from the request.
