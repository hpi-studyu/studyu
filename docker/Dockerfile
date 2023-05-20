FROM ghcr.io/cirruslabs/flutter:stable as builder

# E.g. app or designer
ARG FLUTTER_APP_FOLDER

#RUN flutter config --enable-web

ENV PATH ${PATH}:/root/.pub-cache/bin/

# Install melos
RUN dart pub global activate melos

# SETUP STUDYU
WORKDIR /src/

COPY melos.yaml melos.yaml

COPY pubspec.yaml pubspec.yaml
COPY pubspec.lock pubspec.lock

COPY core/pubspec.yaml core/pubspec.yaml
COPY core/pubspec.lock core/pubspec.lock

COPY flutter_common/pubspec.yaml flutter_common/pubspec.yaml
COPY flutter_common/pubspec.lock flutter_common/pubspec.lock

COPY $FLUTTER_APP_FOLDER/pubspec.yaml $FLUTTER_APP_FOLDER/pubspec.yaml
COPY $FLUTTER_APP_FOLDER/pubspec.lock $FLUTTER_APP_FOLDER/pubspec.lock

RUN flutter pub get
RUN melos cleandocker
RUN melos bootstrap

COPY ./ ./

# Env variable from docker-compose-*.yaml is used here if set
ARG STUDYU_ENV
RUN if [ -n "$STUDYU_ENV" ] ; then melos run build:web:$FLUTTER_APP_FOLDER:$STUDYU_ENV ; else melos run build:web:app ; fi
RUN if [ -n "$STUDYU_ENV" ] ; then melos run build:web:$FLUTTER_APP_FOLDER:$STUDYU_ENV ; else melos run build:web:$FLUTTER_APP_FOLDER ; fi
