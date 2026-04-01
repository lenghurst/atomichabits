## 2024-05-22 - [Edge Function Auth Gap]
**Vulnerability:** The `get-gemini-ephemeral-token` Edge Function was exposed publicly without authentication, allowing anyone to generate valid Gemini API tokens using the project's quota.
**Learning:** New Edge Functions do not inherit authentication by default; developers must explicitly implement `supabase.auth.getUser()` verification. This is easy to miss when copying boilerplate or focusing on functionality.
**Prevention:**
1. Adopt a "Secure by Default" template for new Edge Functions that includes the auth check block.
2. Implement a pre-commit check or linter rule that flags `serve` handlers in `supabase/functions` that don't import/use `supabase.auth`.
