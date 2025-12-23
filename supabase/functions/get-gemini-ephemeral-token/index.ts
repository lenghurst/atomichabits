// Supabase Edge Function: get-gemini-ephemeral-token
// Phase 25.3: Secure ephemeral token generation for Gemini Live API
// Phase 27.17: Enhanced Developer Logging
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
// Phase 27.15: CRITICAL - Must match Flutter app's AIModelConfig.tier2Model
// OLD (Preview - US-only): 'gemini-2.5-flash-native-audio-preview-12-2025'
// NEW (GA - Global): 'gemini-live-2.5-flash-native-audio'
const LIVE_API_MODEL = 'gemini-live-2.5-flash-native-audio'

// Phase 27.17: Developer Logging Helper
function devLog(category: string, message: string, data?: Record<string, unknown>) {
  const timestamp = new Date().toISOString()
  const logEntry = {
    timestamp,
    category,
    message,
    ...data,
  }
  console.log(`[${timestamp}] [${category}] ${message}`, data ? JSON.stringify(data, null, 2) : '')
}

interface EphemeralTokenRequest {
  // Optional: Lock token to specific configuration
  lockToConfig?: boolean
  // Optional: Custom expiry in minutes (default 30)
  expiryMinutes?: number
  // Phase 27.17: Enable verbose logging in response
  debugMode?: boolean
}

interface EphemeralTokenResponse {
  token: string
  expiresAt: string
  model: string
  websocketUrl: string
  // Phase 27.17: Debug info (only included if debugMode is true)
  debug?: {
    tokenRequestTime: string
    googleApiResponseTime: number
    authMethod: string
    userId: string
  }
}

serve(async (req) => {
  const requestId = crypto.randomUUID().substring(0, 8)
  devLog('REQUEST', `[${requestId}] Incoming request`, { method: req.method, url: req.url })
  
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    devLog('CORS', `[${requestId}] Preflight request handled`)
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // === 1. AUTHENTICATE USER ===
    devLog('AUTH', `[${requestId}] Checking authorization header`)
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      devLog('AUTH', `[${requestId}] ❌ Missing authorization header`)
      return new Response(
        JSON.stringify({ error: 'Missing authorisation header' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Verify Supabase JWT
    devLog('AUTH', `[${requestId}] Verifying Supabase JWT`)
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY')!
    const supabase = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } }
    })

    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      devLog('AUTH', `[${requestId}] ❌ Invalid or expired token`, { error: authError?.message })
      return new Response(
        JSON.stringify({ error: 'Invalid or expired token' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }
    devLog('AUTH', `[${requestId}] ✅ User authenticated`, { userId: user.id.substring(0, 8) + '...' })

    // === 2. CHECK API KEY ===
    devLog('CONFIG', `[${requestId}] Checking GEMINI_API_KEY configuration`)
    if (!GEMINI_API_KEY) {
      devLog('CONFIG', `[${requestId}] ❌ GEMINI_API_KEY not configured in environment`)
      console.error('GEMINI_API_KEY not configured in environment')
      return new Response(
        JSON.stringify({ error: 'Service not configured' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }
    devLog('CONFIG', `[${requestId}] ✅ GEMINI_API_KEY configured (${GEMINI_API_KEY.substring(0, 8)}...)`)

    // === 3. PARSE REQUEST ===
    let requestBody: EphemeralTokenRequest = {}
    if (req.method === 'POST') {
      try {
        requestBody = await req.json()
        devLog('REQUEST', `[${requestId}] Request body parsed`, { 
          lockToConfig: requestBody.lockToConfig,
          expiryMinutes: requestBody.expiryMinutes,
          debugMode: requestBody.debugMode,
        })
      } catch {
        devLog('REQUEST', `[${requestId}] Empty request body, using defaults`)
      }
    }

    const expiryMinutes = requestBody.expiryMinutes ?? 30
    const lockToConfig = requestBody.lockToConfig ?? true
    const debugMode = requestBody.debugMode ?? false

    // === 4. REQUEST EPHEMERAL TOKEN FROM GOOGLE ===
    devLog('GOOGLE_API', `[${requestId}] Preparing ephemeral token request`, {
      model: LIVE_API_MODEL,
      apiVersion: GEMINI_API_VERSION,
      expiryMinutes,
      lockToConfig,
    })
    
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
      devLog('GOOGLE_API', `[${requestId}] Token locked to config`, { model: LIVE_API_MODEL })
    }

    // Call Google's auth token endpoint
    const googleApiUrl = `${GEMINI_BASE_URL}/${GEMINI_API_VERSION}/authTokens?key=${GEMINI_API_KEY.substring(0, 8)}...`
    devLog('GOOGLE_API', `[${requestId}] Calling Google API`, { url: googleApiUrl })
    
    const googleApiStartTime = Date.now()
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
    const googleApiResponseTime = Date.now() - googleApiStartTime

    if (!tokenResponse.ok) {
      const errorText = await tokenResponse.text()
      devLog('GOOGLE_API', `[${requestId}] ❌ Google API error`, {
        status: tokenResponse.status,
        error: errorText,
        responseTime: googleApiResponseTime,
      })
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
    devLog('GOOGLE_API', `[${requestId}] ✅ Token received from Google`, {
      responseTime: googleApiResponseTime,
      tokenName: tokenData.name ? tokenData.name.substring(0, 20) + '...' : 'N/A',
    })

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
      devLog('ANALYTICS', `[${requestId}] Token usage logged to database`)
    } catch (logError) {
      // Non-critical, don't fail the request
      devLog('ANALYTICS', `[${requestId}] ⚠️ Failed to log token usage (non-critical)`, { error: String(logError) })
    }

    // === 6. RETURN TOKEN TO CLIENT ===
    const websocketUrl = `wss://generativelanguage.googleapis.com/${GEMINI_API_VERSION}/models/${LIVE_API_MODEL}:streamGenerateContent`
    
    const response: EphemeralTokenResponse = {
      token: tokenData.name, // The ephemeral token string
      expiresAt: expireTime.toISOString(),
      model: LIVE_API_MODEL,
      websocketUrl,
    }
    
    // Include debug info if requested
    if (debugMode) {
      response.debug = {
        tokenRequestTime: now.toISOString(),
        googleApiResponseTime,
        authMethod: 'supabase_jwt',
        userId: user.id.substring(0, 8) + '...',
      }
    }
    
    devLog('RESPONSE', `[${requestId}] ✅ Sending successful response`, {
      model: LIVE_API_MODEL,
      expiresAt: expireTime.toISOString(),
      websocketUrl: websocketUrl.substring(0, 50) + '...',
    })

    return new Response(
      JSON.stringify(response),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    devLog('ERROR', `[${requestId}] ❌ Unexpected error`, { error: String(error) })
    console.error('Unexpected error:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
