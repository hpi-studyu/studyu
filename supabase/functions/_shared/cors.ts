// todo should be
export const corsHeaders = {
  'Access-Control-Allow-Origin': '*', // todo do not use wildcard in production, restrict to your actual frontend URL
  'Access-Control-Allow-Headers': 'api-key, x-client-info, content-type', // api-key is our custom header for studyu user api keys
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
}
