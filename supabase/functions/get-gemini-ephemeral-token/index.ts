// Supabase Edge Function: get-gemini-ephemeral-token
// Phase 25.3: Secure ephemeral token generation for Gemini Live API
//
// This function:
// 1. Authenticates the user via Supabase Auth JWT
// 2. Requests an ephemeral token from Google's Gemini API
// 3. Returns the short-lived token to the Flutter client
//
// The ephemeral token is valid for ~30 minutes and can only start 1 session.
// This prevents API key exposure in client-side applications.

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// CORS headers for Flutter web support
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// Gemini API configuration
const GEMINI_API_KEY = Deno.env.get('GEMINI_API_KEY')
const GEMINI_API_VERSION = 'v1alpha'
const GEMINI_BASE_URL = 'https://generativelanguage.googleapis.com'

// Model configuration (December 2025 verified endpoints)
const LIVE_API_MODEL = 'gemini-2.5-flash-native-audio-preview-12-2025'

interface EphemeralTokenRequest {
  // Optional: Lock token to specific configuration
  lockToConfig?: boolean
  // Optional: Custom expiry in minutes (default 30)
  expiryMinutes?: number
}

interface EphemeralTokenResponse {
  token: string
  expiresAt: string
  model: string
  websocketUrl: string
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // === 1. AUTHENTICATE USER ===
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'Missing authorisation header' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Verify Supabase JWT
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY')!
    const supabase = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } }
    })

    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: 'Invalid or expired token' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // === 2. CHECK API KEY ===
    if (!GEMINI_API_KEY) {
      console.error('GEMINI_API_KEY not configured in environment')
      return new Response(
        JSON.stringify({ error: 'Service not configured' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // === 3. PARSE REQUEST ===
    let requestBody: EphemeralTokenRequest = {}
    if (req.method === 'POST') {
      try {
        requestBody = await req.json()
      } catch {
        // Empty body is fine, use defaults
      }
    }

    const expiryMinutes = requestBody.expiryMinutes ?? 30
    const lockToConfig = requestBody.lockToConfig ?? true

    // === 4. REQUEST EPHEMERAL TOKEN FROM GOOGLE ===
    const now = new Date()
    const expireTime = new Date(now.getTime() + expiryMinutes * 60 * 1000)
    const newSessionExpireTime = new Date(now.getTime() + 60 * 1000) // 1 minute to start session

    // Build the token request payload
    const tokenRequestPayload: Record<string, unknown> = {
      uses: 1, // Single session only
      expire_time: expireTime.toISOString(),
      new_session_expire_time: newSessionExpireTime.toISOString(),
    }

    // Optionally lock token to specific configuration (enhanced security)
    if (lockToConfig) {
      tokenRequestPayload.live_connect_constraints = {
        model: LIVE_API_MODEL,
        config: {
          session_resumption: {},
          temperature: 0.7,
          response_modalities: ['AUDIO'],
        }
      }
    }

    // Call Google's auth token endpoint
    const tokenResponse = await fetch(
      `${GEMINI_BASE_URL}/${GEMINI_API_VERSION}/authTokens?key=${GEMINI_API_KEY}`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(tokenRequestPayload),
      }
    )

    if (!tokenResponse.ok) {
      const errorText = await tokenResponse.text()
      console.error('Gemini API error:', tokenResponse.status, errorText)
      return new Response(
        JSON.stringify({ 
          error: 'Failed to generate ephemeral token',
          details: tokenResponse.status === 403 ? 'API key may be invalid' : 'Service unavailable'
        }),
        { status: 502, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const tokenData = await tokenResponse.json()

    // === 5. LOG USAGE (Optional: for analytics) ===
    // You can log token generation to a Supabase table for monitoring
    try {
      await supabase.from('ai_token_usage').insert({
        user_id: user.id,
        model: LIVE_API_MODEL,
        token_type: 'ephemeral',
        created_at: now.toISOString(),
        expires_at: expireTime.toISOString(),
      })
    } catch (logError) {
      // Non-critical, don't fail the request
      console.warn('Failed to log token usage:', logError)
    }

    // === 6. RETURN TOKEN TO CLIENT ===
    const response: EphemeralTokenResponse = {
      token: tokenData.name, // The ephemeral token string
      expiresAt: expireTime.toISOString(),
      model: LIVE_API_MODEL,
      websocketUrl: `wss://generativelanguage.googleapis.com/${GEMINI_API_VERSION}/models/${LIVE_API_MODEL}:streamGenerateContent`,
    }

    return new Response(
      JSON.stringify(response),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Unexpected error:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
