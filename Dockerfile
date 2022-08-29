FROM cirrusci/flutter:latest as builder

# E.g. app or designer
ARG FLUTTER_APP_FOLDER

ENV PATH ${PATH}:/root/.pub-cache/bin/

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
ENV FLUTTER_APP_FOLDER ${FLUTTER_APP_FOLDER}

# We need to modify the nginx conf to redirect all links to index.html for designer_v2
COPY ./docker/nginx/default.conf /etc/nginx/conf.d/default.conf

COPY ./docker/nginx/designer2-stage.hpi.studyu.health.conf /etc/nginx/conf.d/designer2-stage.hpi.studyu.health.conf

# todo get ssl certs from elsewhere
COPY ./hpi.studyu.health /etc/nginx/certs

COPY --from=builder /src/$FLUTTER_APP_FOLDER/build/web /usr/share/nginx/html/$FLUTTER_APP_FOLDER

# Loads all env vars starting with "STUDYU" into the .env file used by both Flutter apps
RUN mkdir /usr/share/nginx/html/$FLUTTER_APP_FOLDER/assets/envs
CMD ["sh", "-c", "printenv | grep STUDYU_ > /usr/share/nginx/html/$FLUTTER_APP_FOLDER/assets/envs/.env && nginx -g 'daemon off;'"]

EXPOSE 80 443
