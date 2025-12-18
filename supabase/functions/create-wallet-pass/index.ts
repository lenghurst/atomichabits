// Supabase Edge Function: create-wallet-pass
// Phase 25.9: Google Wallet Pass JWT Signing Service with Viral Referral
//
// SME Recommendation (Sean Ellis - Growth Hacking):
// "The Google Wallet Pass MUST contain the user's unique referral code
// embedded in the QR code. This is your 'Trojan Horse'."
//
// This function:
// 1. Authenticates the user via Supabase Auth JWT
// 2. Generates/retrieves user's unique referral code
// 3. Creates a GenericObject with referral deep link in QR code
// 4. Signs the JWT using the Google Cloud service account key
// 5. Returns the "Add to Google Wallet" URL
//
// Required Environment Variables:
// - GOOGLE_WALLET_ISSUER_ID: Your Google Wallet Issuer ID
// - GOOGLE_WALLET_SERVICE_ACCOUNT_EMAIL: Service account email
// - GOOGLE_WALLET_PRIVATE_KEY: Service account private key (PEM format)

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { create, getNumericDate } from 'https://deno.land/x/djwt@v3.0.2/mod.ts'

// CORS headers for Flutter web support
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// Google Wallet configuration
const ISSUER_ID = Deno.env.get('GOOGLE_WALLET_ISSUER_ID')
const SERVICE_ACCOUNT_EMAIL = Deno.env.get('GOOGLE_WALLET_SERVICE_ACCOUNT_EMAIL')
const PRIVATE_KEY = Deno.env.get('GOOGLE_WALLET_PRIVATE_KEY')

// The Pact branding
const PACT_LOGO_URL = 'https://thepact.co/assets/branding/pact_logo_wallet.png'
const PACT_HERO_IMAGE_URL = 'https://thepact.co/assets/branding/pact_hero_wallet.png'
const PACT_HEX_COLOUR = '#2C1810' // Grimoire dark brown
const PACT_BASE_URL = 'https://thepact.co'

interface CreatePassRequest {
  // The Pact details
  pactName: string           // e.g., "Read 1 page daily"
  pactIdentity: string       // e.g., "I am a reader"
  pactEmoji: string          // e.g., "📚"
  
  // User details
  userName: string           // Display name
  
  // Optional customisation
  streakCount?: number       // Current streak
  startDate?: string         // ISO date string
  
  // Unique identifiers
  pactId: string             // UUID of the pact/habit
  
  // Referral (optional - will be generated if not provided)
  referralCode?: string      // User's unique referral code
}

interface CreatePassResponse {
  saveUrl: string            // "Add to Google Wallet" URL
  passId: string             // The pass object ID
  referralCode: string       // The referral code embedded in the pass
  referralUrl: string        // Full referral URL for sharing
  expiresAt: string          // When the JWT expires
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

    // === 2. VALIDATE CONFIGURATION ===
    if (!ISSUER_ID || !SERVICE_ACCOUNT_EMAIL || !PRIVATE_KEY) {
      console.error('Google Wallet configuration missing')
      return new Response(
        JSON.stringify({ error: 'Service not configured' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // === 3. PARSE REQUEST ===
    if (req.method !== 'POST') {
      return new Response(
        JSON.stringify({ error: 'Method not allowed' }),
        { status: 405, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const requestBody: CreatePassRequest = await req.json()
    
    // Validate required fields
    if (!requestBody.pactName || !requestBody.pactId) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields: pactName, pactId' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // === 4. GET OR GENERATE REFERRAL CODE ===
    // Sean Ellis: "The QR code must be a deep link with referral code"
    let referralCode = requestBody.referralCode
    
    if (!referralCode) {
      // Try to get existing referral code from database
      const { data: existingCode } = await supabase
        .from('referral_codes')
        .select('code')
        .eq('user_id', user.id)
        .single()
      
      if (existingCode?.code) {
        referralCode = existingCode.code
      } else {
        // Generate new referral code (6 alphanumeric characters)
        referralCode = generateReferralCode(user.id)
        
        // Store the new code
        await supabase.from('referral_codes').insert({
          user_id: user.id,
          code: referralCode,
          created_at: new Date().toISOString(),
        })
      }
    }
    
    // Build the viral referral URL
    const referralUrl = `${PACT_BASE_URL}/c/${referralCode}`

    // === 5. CREATE PASS OBJECT ===
    const classSuffix = 'thepact_commitment'
    const objectSuffix = `${user.id}_${requestBody.pactId}`.replace(/-/g, '_')
    
    const classId = `${ISSUER_ID}.${classSuffix}`
    const objectId = `${ISSUER_ID}.${objectSuffix}`
    
    // Build the GenericClass (defines the pass template)
    const genericClass = {
      id: classId,
      classTemplateInfo: {
        cardTemplateOverride: {
          cardRowTemplateInfos: [
            {
              twoItems: {
                startItem: {
                  firstValue: {
                    fields: [{ fieldPath: "object.textModulesData['streak']" }]
                  }
                },
                endItem: {
                  firstValue: {
                    fields: [{ fieldPath: "object.textModulesData['identity']" }]
                  }
                }
              }
            },
            {
              oneItem: {
                item: {
                  firstValue: {
                    fields: [{ fieldPath: "object.textModulesData['referral']" }]
                  }
                }
              }
            }
          ]
        }
      }
    }
    
    // Build the GenericObject (the actual pass instance)
    const now = new Date()
    const startDate = requestBody.startDate 
      ? new Date(requestBody.startDate) 
      : now
    
    const genericObject = {
      id: objectId,
      classId: classId,
      state: 'ACTIVE',
      
      // Pass header
      cardTitle: {
        defaultValue: {
          language: 'en-GB',
          value: 'The Pact'
        }
      },
      header: {
        defaultValue: {
          language: 'en-GB',
          value: `${requestBody.pactEmoji || '📜'} ${requestBody.pactName}`
        }
      },
      subheader: {
        defaultValue: {
          language: 'en-GB',
          value: requestBody.pactIdentity || 'My Commitment'
        }
      },
      
      // Branding
      hexBackgroundColor: PACT_HEX_COLOUR,
      logo: {
        sourceUri: {
          uri: PACT_LOGO_URL
        },
        contentDescription: {
          defaultValue: {
            language: 'en-GB',
            value: 'The Pact Logo'
          }
        }
      },
      heroImage: {
        sourceUri: {
          uri: PACT_HERO_IMAGE_URL
        },
        contentDescription: {
          defaultValue: {
            language: 'en-GB',
            value: 'The Pact - Your Social Contract'
          }
        }
      },
      
      // Data modules
      textModulesData: [
        {
          id: 'streak',
          header: 'Current Streak',
          body: `${requestBody.streakCount || 0} days`
        },
        {
          id: 'identity',
          header: 'Identity',
          body: requestBody.pactIdentity || 'Committed'
        },
        {
          id: 'started',
          header: 'Pact Signed',
          body: startDate.toLocaleDateString('en-GB', { 
            day: 'numeric', 
            month: 'short', 
            year: 'numeric' 
          })
        },
        {
          id: 'referral',
          header: 'Invite Friends',
          body: `Share your code: ${referralCode}`
        }
      ],
      
      // Links - includes referral link prominently
      linksModuleData: {
        uris: [
          {
            uri: referralUrl,
            description: 'Invite a Friend',
            id: 'invite_link'
          },
          {
            uri: `${PACT_BASE_URL}/pact/${requestBody.pactId}`,
            description: 'View in The Pact',
            id: 'view_pact'
          },
          {
            uri: PACT_BASE_URL,
            description: 'thepact.co',
            id: 'website'
          }
        ]
      },
      
      // QR code - NOW CONTAINS REFERRAL DEEP LINK (Sean Ellis's recommendation)
      // When someone scans this QR code from an Instagram Story, they get:
      // 1. Directed to the app store with the referral code
      // 2. The code is passed through to the app on first launch
      barcode: {
        type: 'QR_CODE',
        value: referralUrl,  // CRITICAL: This is the viral vector
        alternateText: `Scan to join The Pact (${referralCode})`
      },
      
      // Notifications
      notifications: {
        expiryNotification: {
          enableNotification: false
        }
      },
      
      // Validity
      validTimeInterval: {
        start: {
          date: startDate.toISOString()
        }
        // No end date - the pact is eternal until broken
      }
    }

    // === 6. CREATE AND SIGN JWT ===
    const claims = {
      iss: SERVICE_ACCOUNT_EMAIL,
      aud: 'google',
      origins: ['https://thepact.co', 'http://localhost'],
      typ: 'savetowallet',
      iat: getNumericDate(0),
      payload: {
        genericClasses: [genericClass],
        genericObjects: [genericObject]
      }
    }

    // Import the private key for signing
    const privateKeyPem = PRIVATE_KEY.replace(/\\n/g, '\n')
    const privateKey = await crypto.subtle.importKey(
      'pkcs8',
      pemToArrayBuffer(privateKeyPem),
      {
        name: 'RSASSA-PKCS1-v1_5',
        hash: 'SHA-256'
      },
      false,
      ['sign']
    )

    // Sign the JWT
    const token = await create(
      { alg: 'RS256', typ: 'JWT' },
      claims,
      privateKey
    )

    // === 7. LOG PASS CREATION ===
    try {
      await supabase.from('wallet_passes').upsert({
        user_id: user.id,
        pact_id: requestBody.pactId,
        pass_object_id: objectId,
        referral_code: referralCode,
        streak_count: requestBody.streakCount || 0,
        created_at: now.toISOString(),
        updated_at: now.toISOString(),
      }, { onConflict: 'user_id,pact_id' })
    } catch (logError) {
      // Non-critical, don't fail the request
      console.warn('Failed to log pass creation:', logError)
    }

    // === 8. RETURN SAVE URL WITH REFERRAL INFO ===
    const saveUrl = `https://pay.google.com/gp/v/save/${token}`
    
    const response: CreatePassResponse = {
      saveUrl,
      passId: objectId,
      referralCode,
      referralUrl,
      expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString() // JWT valid for 24h
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

/**
 * Generate a unique referral code from user ID
 * Format: 6 alphanumeric characters (base36)
 */
function generateReferralCode(userId: string): string {
  // Create a hash from user ID + timestamp for uniqueness
  const input = `${userId}-${Date.now()}`
  let hash = 0
  for (let i = 0; i < input.length; i++) {
    const char = input.charCodeAt(i)
    hash = ((hash << 5) - hash) + char
    hash = hash & hash // Convert to 32-bit integer
  }
  
  // Convert to base36 and take first 6 characters
  const code = Math.abs(hash).toString(36).toUpperCase().padStart(6, '0').slice(0, 6)
  return code
}

/**
 * Convert PEM-encoded private key to ArrayBuffer
 */
function pemToArrayBuffer(pem: string): ArrayBuffer {
  // Remove PEM headers and whitespace
  const base64 = pem
    .replace(/-----BEGIN PRIVATE KEY-----/, '')
    .replace(/-----END PRIVATE KEY-----/, '')
    .replace(/\s/g, '')
  
  // Decode base64
  const binaryString = atob(base64)
  const bytes = new Uint8Array(binaryString.length)
  for (let i = 0; i < binaryString.length; i++) {
    bytes[i] = binaryString.charCodeAt(i)
  }
  return bytes.buffer
}
