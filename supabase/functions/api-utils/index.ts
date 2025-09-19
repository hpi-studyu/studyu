// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'npm:@supabase/supabase-js@2'
//import * as supabase from 'npm:@supabase/supabase-js@2'
import { corsHeaders } from '../_shared/cors.ts'
import * as jwt from "jsr:@cross/jwt";

const SUPABASE_JWT_SECRET='super-secret-jwt-token-with-at-least-32-characters-long'

export function issueUserJwt(userId) {
  const payload = {
    aud: "authenticated",
    sub: userId,
  };
  return jwt.signJWT(payload, SUPABASE_JWT_SECRET, { algorithm: "HS256" });
}

Deno.serve(async (req) => {
  try {
    console.log('Initializing api-utils function')

		const apiKey = req.headers.get('api-key')
		if (!apiKey) {
			return new Response(JSON.stringify({ error: 'Unauthorized' }), {
				headers: { ...corsHeaders, 'Content-Type': 'application/json' },
				status: 401,
			})
		}
		// TODO convert studyu user-specific api key from Authorization header to a user id via api_key table lookup
		const userId = 'cbf4d9fd-7293-4b53-a0e7-c129e87bded0'

    const userJWT = await issueUserJwt(userId)
    const authHeader = "Bearer " + userJWT
    //const authHeader = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwOi8vMTI3LjAuMC4xOjgwODIvYXV0aC92MSIsInN1YiI6ImNiZjRkOWZkLTcyOTMtNGI1My1hMGU3LWMxMjllODdiZGVkMCIsImF1ZCI6ImF1dGhlbnRpY2F0ZWQiLCJleHAiOjE3NTgyOTYxNzcsImlhdCI6MTc1ODI5MjU3NywiZW1haWwiOiJ1c2VyMUBzdHVkeXUuaGVhbHRoIiwicGhvbmUiOiIiLCJhcHBfbWV0YWRhdGEiOnsicHJvdmlkZXIiOiJlbWFpbCIsInByb3ZpZGVycyI6WyJlbWFpbCJdfSwidXNlcl9tZXRhZGF0YSI6e30sInJvbGUiOiJhdXRoZW50aWNhdGVkIiwiYWFsIjoiYWFsMSIsImFtciI6W3sibWV0aG9kIjoicGFzc3dvcmQiLCJ0aW1lc3RhbXAiOjE3NTgyOTI1Nzd9XSwic2Vzc2lvbl9pZCI6ImIwOTQwNzQ1LWJlN2QtNDE3Zi1hODRhLTczMzc4N2E3NWQwYiIsImlzX2Fub255bW91cyI6ZmFsc2V9.WMt56WYxL5mHx6KUTUVGE8LQQaGXtub647nvAdyBstQ"
    //const userJWT = authHeader.replace('Bearer ', '')

    const supabaseClient = createClient(
			Deno.env.get('SUPABASE_URL') ?? '',
			Deno.env.get('SUPABASE_ANON_KEY') ?? '',
			{
				global:
				  {
						headers:
						  {
								Authorization: authHeader!
							}
					}
			}
		)

    const {
      data: { user },
    } = await supabaseClient.auth.getUser(userJWT)

		if (!user) {
			return new Response(JSON.stringify({ error: 'Unauthorized' }), {
				headers: { ...corsHeaders, 'Content-Type': 'application/json' },
				status: 401,
			})
		}

		console.log('User authenticated:', user.id)

		const { data, error } = await supabaseClient.from('study').select('*')
		if (error) {
			return new Response(JSON.stringify({ error: error.message }), {
				headers: { ...corsHeaders, 'Content-Type': 'application/json' },
				status: 400,
			})
		}

		return new Response(JSON.stringify({ data }), {
			headers: { ...corsHeaders, 'Content-Type': 'application/json' },
			status: 200,
		})

  } catch (err) {
    return new Response(String(err?.message ?? err), { status: 500 })
  }
})

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:8082/functions/v1/api-utils' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/
