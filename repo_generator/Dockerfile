FROM google/dart as builder

WORKDIR /app

RUN mkdir /core
ADD core /core/
ADD repo_generator/pubspec.* /app/
RUN pub get
ADD repo_generator/. /app
RUN pub get --offline

RUN dart compile exe bin/repo_generator.dart

FROM python:latest

RUN pip install git+https://github.com/copier-org/copier.git@1f24b5a02e33960cd7d71c998e475b253efd62ae

COPY --from=builder /app/bin/repo_generator.exe /usr/local/bin/repo_generator

ADD repo_generator/.env .env

CMD ["/usr/local/bin/repo_generator"]
