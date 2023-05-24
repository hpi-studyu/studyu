FROM ghcr.io/cirruslabs/flutter:stable as builder

ENV PATH ${PATH}:/root/.pub-cache/bin/

# Create workdir
WORKDIR /src/

# Install melos
RUN dart pub global activate melos

# Copy repository files
COPY ./ ./

# Clean repository without failing
RUN melos clean

# Setup workspace
RUN dart pub get
RUN melos bootstrap

ARG STUDYU_ENV

# Build apps
RUN melos run build:web:app:$STUDYU_ENV
RUN melos run build:web:designer_v2:$STUDYU_ENV

# Configure webserver
FROM nginx:stable-alpine

# Copy web builds from the builder image to the webserver
COPY --from=builder /src/app/build/web /usr/share/nginx/html/app
COPY --from=builder /src/designer_v2/build/web /usr/share/nginx/html/designer_v2

# Loads all env vars starting with "STUDYU" into the .env file for flutter apps
#RUN mkdir /usr/share/nginx/html/app/assets/envs
#RUN mkdir /usr/share/nginx/html/designer_v2/assets/envs

#CMD ["sh", "-c", "printenv | grep STUDYU_ > /usr/share/nginx/html/app/assets/envs/.env && nginx -g 'daemon off;'"]
#CMD ["sh", "-c", "printenv | grep STUDYU_ > /usr/share/nginx/html/designer_v2/assets/envs/.env && nginx -g 'daemon off;'"]
