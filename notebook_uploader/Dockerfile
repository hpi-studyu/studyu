FROM google/dart as builder

WORKDIR /app

RUN mkdir /core
ADD core /core/
ADD notebook_uploader/pubspec.* /app/
RUN pub get
ADD notebook_uploader/. /app
RUN pub get --offline

RUN dart compile exe bin/uploader.dart

FROM python:latest

RUN apt-get update && apt-get install -y --no-install-recommends build-essential r-base r-base-dev r-cran-devtools r-cran-roxygen2 r-cran-geepack r-cran-psych r-cran-ggplot2 r-cran-caret r-cran-doparallel libv8-dev

RUN pip install jupyter nbconvert pipreqsnb

RUN Rscript -e "devtools::install_github('thogaertner/cinof1')"

# Install R Kernel
RUN Rscript -e "devtools::install_github('IRkernel/IRkernel')"
RUN Rscript -e "IRkernel::installspec()"

COPY --from=builder /app/bin/uploader.exe /usr/local/bin/uploader

ADD notebook_uploader/nbconvert-template /nbconvert-template

ADD notebook_uploader/generate-notebook-htmls.sh /generate-notebook-htmls.sh

RUN chmod +x /generate-notebook-htmls.sh
