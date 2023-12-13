#!/bin/sh

# Loads all env vars starting with "STUDYU" into the .env file
printenv | grep "^STUDYU_" > /usr/share/nginx/html/"${FLUTTER_APP_FOLDER}"/assets/packages/studyu_flutter_common/envs/.env

# Start Nginx
# nginx -g 'daemon off;'
