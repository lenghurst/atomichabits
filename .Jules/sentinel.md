## 2024-05-23 - [Supabase Edge Function Auth Gap]
**Vulnerability:** The `get-gemini-ephemeral-token` Supabase Edge Function was publicly accessible without authentication, allowing any user to generate Gemini tokens and consume the project's API quota.
**Learning:** Edge Functions are not authenticated by default; developers must explicitly verify the JWT using `supabase.auth.getUser()`.
**Prevention:** All sensitive Edge Functions must include a standard authentication block that initializes the Supabase client with the request's Authorization header and verifies the user before processing.
