ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base-python:3.12-alpine3.20
FROM ${BUILD_FROM}

WORKDIR /app

# Install pydanfoss-cloud[mqtt] (zero Home Assistant core dependency) from the pinned release tag.
# gcc + musl-dev are installed only during the pip build (for pycryptodome on musl/ARM64) and
# removed in the same layer to keep the final image small.
ARG PYDANFOSS_REF="2.0.0-alpha.2"
RUN apk add --no-cache git gcc musl-dev \
    && pip install --no-cache-dir \
       "pydanfoss-cloud[mqtt] @ git+https://github.com/aghulas/ha-danfoss-ally.git@${PYDANFOSS_REF}" \
    && apk del git gcc musl-dev

COPY run.sh /run.sh
RUN chmod a+x /run.sh

CMD ["/run.sh"]
