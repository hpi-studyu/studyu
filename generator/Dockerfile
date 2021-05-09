FROM google/dart as builder

WORKDIR /app

RUN mkdir /core
ADD core /core/
ADD generator/pubspec.* /app/
RUN pub get
ADD generator/. /app
RUN pub get --offline

RUN dart compile exe bin/main.dart

FROM python:latest

RUN pip install copier

COPY --from=builder /app/bin/main.exe /usr/local/bin/generator

ADD generator/.env .env

CMD ["/usr/local/bin/generator", "--port", "80"]
