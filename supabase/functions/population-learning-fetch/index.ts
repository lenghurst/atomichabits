/**
 * Population Learning Fetch Edge Function
 *
 * Returns aggregated Beta priors for a given archetype.
 * Used to initialize Thompson Sampling with population-learned priors.
 *
 * GET /population-learning-fetch?archetype=REBEL
 *
 * Response: {
 *   archetype: string,
 *   priors: {
 *     [armId: string]: { alpha: number, beta: number, sampleCount: number }
 *   },
 *   lastUpdated: string
 * }
 */

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (req.method !== 'GET') {
    return new Response(
      JSON.stringify({ error: 'Method not allowed' }),
      { status: 405, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }

  try {
    // Parse URL parameters
    const url = new URL(req.url);
    const archetype = url.searchParams.get('archetype');

    // Validate archetype
    const validArchetypes = [
      'REBEL', 'PERFECTIONIST', 'PROCRASTINATOR',
      'OVERTHINKER', 'PLEASURE_SEEKER', 'PEOPLE_PLEASER'
    ];

    if (!archetype || !validArchetypes.includes(archetype)) {
      return new Response(
        JSON.stringify({
          error: 'Invalid or missing archetype parameter',
          validArchetypes,
        }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Initialize Supabase client (using anon key for read-only access)
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY')!;
    const supabase = createClient(supabaseUrl, supabaseAnonKey);

    // Fetch priors for the archetype
    const { data: priors, error } = await supabase
      .from('archetype_priors')
      .select('arm_id, alpha, beta, sample_count, last_updated')
      .eq('archetype', archetype);

    if (error) {
      console.error('Error fetching priors:', error);
      return new Response(
        JSON.stringify({ error: 'Failed to fetch priors' }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Transform to map format
    const priorsMap: Record<string, { alpha: number; beta: number; sampleCount: number }> = {};
    let latestUpdate: string | null = null;

    for (const prior of priors || []) {
      priorsMap[prior.arm_id] = {
        alpha: prior.alpha,
        beta: prior.beta,
        sampleCount: prior.sample_count,
      };

      if (!latestUpdate || prior.last_updated > latestUpdate) {
        latestUpdate = prior.last_updated;
      }
    }

    return new Response(
      JSON.stringify({
        archetype,
        priors: priorsMap,
        lastUpdated: latestUpdate,
        armCount: Object.keys(priorsMap).length,
      }),
      {
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
          // Cache for 5 minutes
          "Cache-Control": "public, max-age=300",
        }
      }
    );

  } catch (error) {
    console.error("Population learning fetch failed:", error);
    return new Response(
      JSON.stringify({ error: error.message || "Unknown error" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
