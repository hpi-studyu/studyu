FROM ghcr.io/cirruslabs/flutter:stable as builder

ARG FLUTTER_APP_FOLDER

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

# Build app
RUN melos run build:web:$FLUTTER_APP_FOLDER

# Configure webserver
FROM nginx:stable-alpine

ARG FLUTTER_APP_FOLDER

# Copy web builds from the builder image to the webserver
COPY --from=builder /src/$FLUTTER_APP_FOLDER/build/web /usr/share/nginx/html/$FLUTTER_APP_FOLDER

# Copy init script from the builder image to the entrypoint
COPY --from=builder /src/docker/studyu/init_studyu.sh /docker-entrypoint.d/init_studyu.sh
RUN chmod +x /docker-entrypoint.d/init_studyu.sh

# Set environment variables
ENV FLUTTER_APP_FOLDER=$FLUTTER_APP_FOLDER


