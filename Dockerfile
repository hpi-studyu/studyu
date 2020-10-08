FROM cirrusci/flutter:stable as builder

COPY ./core /src/core

# E.g. app or study_designer
ARG FLUTTER_APP_FOLDER

WORKDIR /src/$FLUTTER_APP_FOLDER

COPY ./$FLUTTER_APP_FOLDER/pubspec.yaml ./pubspec.yaml
COPY ./$FLUTTER_APP_FOLDER/pubspec.lock ./pubspec.lock
COPY ./$FLUTTER_APP_FOLDER/.metadata ./metadata

RUN flutter config --enable-web
RUN flutter pub get

COPY ./$FLUTTER_APP_FOLDER/web ./web
COPY ./$FLUTTER_APP_FOLDER/assets ./assets
COPY ./$FLUTTER_APP_FOLDER/lib ./lib

ARG PARSE_APP_ID
ARG PARSE_MASTER_KEY
ARG PARSE_SERVER_URL

RUN echo "PARSE_APP_ID: $PARSE_APP_ID" \
 && echo "PARSE_MASTER_KEY: $PARSE_MASTER_KEY" \
 && echo "PARSE_SERVER_URL: $PARSE_SERVER_URL" \
 && flutter build web -t lib/main_env.dart \
    --dart-define=PARSE_APP_ID=$PARSE_APP_ID \
    --dart-define=PARSE_MASTER_KEY=$PARSE_MASTER_KEY \
    --dart-define=PARSE_SERVER_URL=$PARSE_SERVER_URL

FROM nginx:stable-alpine
ARG FLUTTER_APP_FOLDER
COPY --from=builder /src/$FLUTTER_APP_FOLDER/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]