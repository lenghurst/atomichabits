import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
// Using the REST API directly instead of the SDK to avoid npm dependency issues in Deno environment if not fully configured
// This aligns with the existing implementation style but simplifies the logic as requested

// CORS headers for Flutter web support
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 1. Get MASTER API key from env
    const apiKey = Deno.env.get('GEMINI_API_KEY')
    if (!apiKey) {
        return new Response(
            JSON.stringify({ error: 'Missing GEMINI_API_KEY environment variable' }),
            { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        )
    }

    // 2. Generate Ephemeral Token using Google REST API
    // https://ai.google.dev/api/tokens
    const response = await fetch(
        `https://generativelanguage.googleapis.com/v1alpha/authTokens?key=${apiKey}`,
        {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                config: {
                    uses: 1, // Token works for one session only
                    expireTime: new Date(Date.now() + 30 * 60 * 1000).toISOString(), // 30 min
                    httpOptions: { apiVersion: 'v1alpha' } // REQUIRED for Live API
                }
            })
        }
    );

    if (!response.ok) {
        const errorText = await response.text();
        return new Response(
            JSON.stringify({ error: `Failed to create token: ${errorText}` }),
            { status: response.status, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        )
    }

    const data = await response.json();

    // 3. Return the token to the Flutter app
    // The API returns { name: "authTokens/..." }
    return new Response(
      JSON.stringify({ token: data.name }), 
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    )
  }
})
