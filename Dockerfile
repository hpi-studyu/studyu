# Based on https://github.com/cirruslabs/docker-images-flutter/blob/master/sdk/Dockerfile
FROM cirrusci/android-sdk:30 as builder

# E.g. app or designer
ARG FLUTTER_APP_FOLDER

# SETUP FLUTTER
USER root

ENV FLUTTER_HOME=${HOME}/sdks/flutter
ENV FLUTTER_ROOT=$FLUTTER_HOME

ENV PATH ${PATH}:${FLUTTER_HOME}/bin:${FLUTTER_HOME}/bin/cache/dart-sdk/bin:/root/.pub-cache/bin/

RUN git clone --depth 1 --branch stable https://github.com/flutter/flutter.git ${FLUTTER_HOME}

RUN yes | flutter doctor --android-licenses \
    && flutter doctor \
    && chown -R root:root ${FLUTTER_HOME}

# Install melos
RUN dart pub global activate melos

# SETUP STUDYU
WORKDIR /src/

COPY melos.yaml melos.yaml

COPY core/pubspec.yaml core/pubspec.yaml
COPY core/pubspec.lock core/pubspec.lock

COPY flutter_common/pubspec.yaml flutter_common/pubspec.yaml
COPY flutter_common/pubspec.lock flutter_common/pubspec.lock

COPY $FLUTTER_APP_FOLDER/pubspec.yaml $FLUTTER_APP_FOLDER/pubspec.yaml
COPY $FLUTTER_APP_FOLDER/pubspec.lock $FLUTTER_APP_FOLDER/pubspec.lock

RUN melos clean
RUN melos bootstrap

COPY ./ ./

# Can be 'selfhost'
ARG ENV

# Env variable from docker-compose-*.yaml is used here if set
RUN if [ -n "$ENV" ] ; then melos run build:web:$FLUTTER_APP_FOLDER:$ENV ; else melos run build:web:$FLUTTER_APP_FOLDER ; fi

FROM nginx:stable-alpine
ARG FLUTTER_APP_FOLDER
COPY --from=builder /src/$FLUTTER_APP_FOLDER/build/web /usr/share/nginx/html
RUN mkdir /usr/share/nginx/html/assets/envs

EXPOSE 80

# Loads all env vars starting with "STUDYU" into the .env file used by both Flutter apps
CMD ["sh", "-c", "printenv | grep STUDYU_ > /usr/share/nginx/html/assets/envs/.env && nginx -g 'daemon off;'"]
