FROM cirrusci/flutter:latest as builder

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

COPY app/pubspec.yaml app/pubspec.yaml
COPY app/pubspec.lock app/pubspec.lock
COPY designer_v2/pubspec.yaml designer_v2/pubspec.yaml
COPY designer_v2/pubspec.lock designer_v2/pubspec.lock

RUN melos clean
RUN melos bootstrap

COPY ./ ./

# Can be 'selfhost'
ARG ENV

# Env variable from docker-compose-*.yaml is used here if set
RUN if [ -n "$ENV" ] ; then melos run build:web:app:$ENV ; else melos run build:web:app ; fi
RUN if [ -n "$ENV" ] ; then melos run build:web:designer_v2:$ENV ; else melos run build:web:designer_v2 ; fi

# todo move nginx to different docker (compose?) file to run it independently when running multiple flutter apps together
FROM nginx:stable-alpine
ARG FLUTTER_APP_FOLDER
ENV FLUTTER_APP_FOLDER ${FLUTTER_APP_FOLDER}

# We need to modify the nginx conf to redirect all links to index.html for designer_v2
COPY ./docker/hpi/nginx/default.conf /etc/nginx/conf.d/default.conf

COPY ./docker/hpi/nginx/app.hpi.studyu.health.conf /etc/nginx/conf.d/app.hpi.studyu.health.conf
COPY ./docker/hpi/nginx/designer2.hpi.studyu.health.conf /etc/nginx/conf.d/designer2.hpi.studyu.health.conf

# todo get ssl certs from elsewhere
COPY ./docker/hpi/hpi.studyu.health /etc/nginx/certs

COPY --from=builder /src/app/build/web /usr/share/nginx/html/app
COPY --from=builder /src/designer_v2/build/web /usr/share/nginx/html/designer_v2

# Loads all env vars starting with "STUDYU" into the .env file used by both Flutter apps
RUN mkdir /usr/share/nginx/html/app/assets/envs
RUN mkdir /usr/share/nginx/html/designer_v2/assets/envs
CMD ["sh", "-c", "printenv | grep STUDYU_ > /usr/share/nginx/html/app/assets/envs/.env && nginx -g 'daemon off;'"]
CMD ["sh", "-c", "printenv | grep STUDYU_ > /usr/share/nginx/html/designer_v2/assets/envs/.env && nginx -g 'daemon off;'"]

EXPOSE 80 443
