FROM dart:stable AS builder

WORKDIR /app

RUN mkdir /core
ADD core /core/
ADD notebook_uploader/pubspec.* /app/
RUN dart pub get
ADD notebook_uploader/. /app
RUN dart pub get --offline

RUN dart compile exe bin/notebook_uploader.dart

FROM mambaorg/micromamba:0.19.0

ADD notebook_uploader/env.yml /tmp/env.yml
RUN micromamba install -y -n base -f /tmp/env.yml && \
    micromamba clean --all --yes

# Install https://github.com/thogaertner/cinof1
RUN Rscript -e "devtools::install_github('thogaertner/cinof1')"

COPY --from=builder /app/bin/notebook_uploader.exe /usr/local/bin/uploader

ADD notebook_uploader/nbconvert-template /nbconvert-template
ADD --chown=micromamba:micromamba notebook_uploader/generate-notebook-htmls.sh /generate-notebook-htmls.sh

RUN chmod +x /generate-notebook-htmls.sh
