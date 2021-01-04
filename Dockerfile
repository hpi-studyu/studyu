FROM cirrusci/flutter:beta as builder

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

RUN flutter build web --pwa-strategy none --web-renderer auto

FROM nginx:stable-alpine
ARG FLUTTER_APP_FOLDER
COPY --from=builder /src/$FLUTTER_APP_FOLDER/build/web /usr/share/nginx/html
RUN mkdir /usr/share/nginx/html/assets/envs

EXPOSE 80

# Loads all env vars starting with "FLUTTER_" into the .env file used by both Flutter apps
CMD ["sh", "-c", "printenv | grep FLUTTER_ > /usr/share/nginx/html/assets/envs/.env && nginx -g 'daemon off;'"]
