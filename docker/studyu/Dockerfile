FROM debian:latest as builder

RUN apt-get update
RUN apt-get install -y bash curl file git libglu1-mesa unzip which xz-utils zip
RUN apt-get clean

# todo use root user again
RUN useradd -ms /bin/bash bob
USER bob

ENV HOME=/home/bob
ENV PATH="${PATH}:${HOME}/flutter/bin:${HOME}/.pub-cache/bin"

RUN git clone -b master https://github.com/flutter/flutter.git ~/flutter
# todo use stable if building error is fixed
# RUN flutter channel stable
RUN flutter config --enable-web
RUN flutter upgrade
RUN flutter doctor -v

ARG FLUTTER_APP_FOLDER

# Create workdir and copy files
RUN mkdir ~/src/
COPY --chown=bob:bob . ~/src/
WORKDIR ~/src/

# Disable parallel pub get
RUN sed -i 's/runPubGetInParallel: true/runPubGetInParallel: false/' melos.yaml

# Install melos
RUN dart pub global activate melos

# Clean repository without failing
RUN melos --verbose clean

# Setup workspace
RUN dart pub get
RUN melos --verbose bootstrap

# Build app
RUN melos --verbose run build:web:$FLUTTER_APP_FOLDER

# Configure webserver
FROM nginx:stable-alpine

ARG FLUTTER_APP_FOLDER

# Copy web builds from the builder image to the webserver
COPY --from=builder ~/src/$FLUTTER_APP_FOLDER/build/web /usr/share/nginx/html/$FLUTTER_APP_FOLDER

# Copy init script from the builder image to the entrypoint
COPY --from=builder ~/src/docker/studyu/init_studyu.sh /docker-entrypoint.d/init_studyu.sh
RUN chmod +x /docker-entrypoint.d/init_studyu.sh

# Set environment variables
ENV FLUTTER_APP_FOLDER=$FLUTTER_APP_FOLDER
