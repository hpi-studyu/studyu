FROM kong:2.8.1

# Switch to the root user temporarily for installation
USER root

# Install gettext for envsubst
ENV BUILD_DEPS="gettext" \
    RUNTIME_DEPS="libintl"

RUN set -x && \
    apk add --update $RUNTIME_DEPS && \
    apk add --virtual build_deps $BUILD_DEPS &&  \
    cp /usr/bin/envsubst /usr/local/bin/envsubst && \
    apk del build_deps

# Copy the kong.yml template file into the container
COPY ./volumes/api/kong.yml.template /home/kong/kong.yml.template

# Switch back to kong user
USER kong

# ADD entrypoint.sh /etc/bootstrap.sh
ENTRYPOINT ["/bin/sh","-c"]

CMD ["envsubst '${ANON_KEY},${SERVICE_KEY}' < /home/kong/kong.yml.template > /home/kong/kong.yml && /docker-entrypoint.sh kong docker-start"]
