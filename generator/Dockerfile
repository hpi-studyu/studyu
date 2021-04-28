FROM google/dart as builder

WORKDIR /app

RUN mkdir /core
ADD ../core /core/
ADD generator/pubspec.* /app/
RUN pub get
ADD generator/. /app
RUN pub get --offline

RUN dart compile exe bin/uploader.dart

FROM python:latest

RUN pip install jupyter nbconvert

COPY --from=builder /app/bin/uploader.exe /usr/local/bin/uploader

ADD generator/nbconvert-template /nbconvert-template