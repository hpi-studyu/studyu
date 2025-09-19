// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'npm:@supabase/supabase-js@2'
//import * as supabase from 'npm:@supabase/supabase-js@2'
import * as jwt from "jsr:@cross/jwt";

const SUPABASE_JWT_SECRET='super-secret-jwt-token-with-at-least-32-characters-long'
const PROJECT_REF = 'http://127.0.0.1:8082'; // Deno.env.get('SUPABASE_PROJECT_REF')

export function issueUserJwt(userId, email) {
  const now = Math.floor(Date.now() / 1000);

  const payload = {
    iss: `${PROJECT_REF}/auth/v1`,
    aud: "authenticated",
    exp: now + 60 * 60, // 1 hour
    iat: now,
    sub: userId,
    role: "authenticated",
    aal: "aal1", // default assurance level
    email: email,
    phone: "",
    is_anonymous: false,
  };

  return jwt.signJWT(payload, SUPABASE_JWT_SECRET, { algorithm: "HS256" });
}

Deno.serve(async (req) => {
  try {
    console.log('Initializing api-utils function')

		// todo convert studyu user-specific api key from Authorization header to a user id via api_key table lookup
    const userJWT = await issueUserJwt("cbf4d9fd-7293-4b53-a0e7-c129e87bded0", "user1@studyu.health")

    const supabaseClient = createClient(
			Deno.env.get('SUPABASE_URL') ?? '',
			Deno.env.get('SUPABASE_ANON_KEY') ?? '',
			{ global: { headers: { Authorization: userJWT! } } }
		)

		console.log('User JWT:', userJWT)

    const {
      data: { user },
    } = await supabaseClient.auth.getUser(userJWT)

		if (!user) {
			return new Response(JSON.stringify({ error: 'Unauthorized' }), {
				headers: { 'Content-Type': 'application/json' },
				status: 401,
			})
		}

		console.log('User authenticated:', user.id, user.email)

		return new Response(JSON.stringify({ user }), {
			headers: { 'Content-Type': 'application/json' },
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
