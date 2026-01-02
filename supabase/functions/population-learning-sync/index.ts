/**
 * Population Learning Sync Edge Function
 *
 * Receives Beta parameters from clients and aggregates them into population priors.
 * Privacy-preserving: Uses hashed user IDs for rate limiting, only stores (alpha, beta).
 *
 * POST /population-learning-sync
 * Body: {
 *   userHash: string,      // SHA256 hash of user ID
 *   archetype: string,     // e.g., "REBEL", "PERFECTIONIST"
 *   outcomes: [
 *     { armId: string, success: boolean }
 *   ]
 * }
 */

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

// Learning rate for Bayesian update (how much new data affects priors)
const LEARNING_RATE = 0.1;

// Minimum samples before contributing to population
const MIN_SAMPLES_THRESHOLD = 5;

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (req.method !== 'POST') {
    return new Response(
      JSON.stringify({ error: 'Method not allowed' }),
      { status: 405, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }

  try {
    // Parse request body
    const body = await req.json();
    const { userHash, archetype, outcomes } = body;

    // Validate required fields
    if (!userHash || !archetype || !outcomes || !Array.isArray(outcomes)) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields: userHash, archetype, outcomes' }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Validate archetype
    const validArchetypes = [
      'REBEL', 'PERFECTIONIST', 'PROCRASTINATOR',
      'OVERTHINKER', 'PLEASURE_SEEKER', 'PEOPLE_PLEASER'
    ];
    if (!validArchetypes.includes(archetype)) {
      return new Response(
        JSON.stringify({ error: 'Invalid archetype' }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Check rate limiting FIRST (one contribution session per 24h per user/archetype)
    // This prevents users from contributing multiple times per day for the same archetype
    const { data: existingLog } = await supabase
      .from('contribution_log')
      .select('id')
      .eq('user_hash', userHash)
      .eq('archetype', archetype)
      .limit(1)
      .maybeSingle();

    if (existingLog) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'rate_limited',
          message: 'Already contributed for this archetype in the last 24 hours'
        }),
        { status: 429, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Process each outcome
    const results = [];
    for (const outcome of outcomes) {
      const { armId, success } = outcome;

      if (!armId || typeof success !== 'boolean') {
        continue; // Skip invalid outcomes
      }

      // Get current priors
      const { data: prior, error: priorError } = await supabase
        .from('archetype_priors')
        .select('*')
        .eq('archetype', archetype)
        .eq('arm_id', armId)
        .single();

      if (priorError && priorError.code !== 'PGRST116') {
        console.error('Error fetching prior:', priorError);
        results.push({ armId, status: 'error' });
        continue;
      }

      // Calculate update
      const currentAlpha = prior?.alpha ?? 1.0;
      const currentBeta = prior?.beta ?? 1.0;
      const sampleCount = prior?.sample_count ?? 0;

      // Bayesian update with learning rate
      const newAlpha = currentAlpha + (success ? LEARNING_RATE : 0);
      const newBeta = currentBeta + (success ? 0 : LEARNING_RATE);

      // Upsert the prior
      const { error: upsertError } = await supabase
        .from('archetype_priors')
        .upsert({
          archetype,
          arm_id: armId,
          alpha: newAlpha,
          beta: newBeta,
          sample_count: sampleCount + 1,
          last_updated: new Date().toISOString(),
        }, {
          onConflict: 'archetype,arm_id'
        });

      if (upsertError) {
        console.error('Error upserting prior:', upsertError);
        results.push({ armId, status: 'error' });
        continue;
      }

      results.push({ armId, status: 'success' });
    }

    // Log the contribution session for rate limiting (once per archetype, not per arm)
    await supabase
      .from('contribution_log')
      .insert({
        user_hash: userHash,
        archetype,
        arm_id: '_session_', // Session marker, not arm-specific
      });

    // Clean old contribution logs (async, fire-and-forget)
    supabase.rpc('clean_old_contributions').then(() => {
      console.log('Cleaned old contribution logs');
    }).catch((e) => {
      console.error('Error cleaning logs:', e);
    });

    return new Response(
      JSON.stringify({
        success: true,
        results,
        message: `Processed ${results.length} outcomes for ${archetype}`
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );

  } catch (error) {
    console.error("Population learning sync failed:", error);
    return new Response(
      JSON.stringify({ error: error.message || "Unknown error" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
