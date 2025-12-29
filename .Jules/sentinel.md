## 2024-05-23 - Critical Auth Bypass in Edge Functions
**Vulnerability:** The `get-gemini-ephemeral-token` function exposed the Gemini API to the public internet without any authentication. It allowed anyone to generate ephemeral tokens and use the API at the project's expense.
**Learning:** Edge Functions in Supabase are public by default unless you explicitly implement JWT verification. It's easy to assume "server-side means secure" or that they inherit some project-level auth, but they are just standard HTTP endpoints.
**Prevention:** Always implement a middleware or helper function for Supabase Edge Functions that validates the `Authorization` header using `supabase.auth.getUser()` before processing any sensitive logic.
