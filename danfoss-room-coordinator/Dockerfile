ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base-python:3.12-alpine3.20
FROM ${BUILD_FROM}

WORKDIR /app

# Install pydanfoss-cloud[mqtt] (zero Home Assistant core dependency) from PyPI, pinned by version.
# gcc + musl-dev are installed only during the pip build and removed in the same layer.
ARG PYDANFOSS_VERSION="0.7.0"
RUN apk add --no-cache gcc musl-dev \
    && pip install --no-cache-dir \
       "pydanfoss-cloud[mqtt]==${PYDANFOSS_VERSION}" \
    && apk del gcc musl-dev

COPY run.sh /run.sh
RUN chmod a+x /run.sh

CMD ["/run.sh"]
