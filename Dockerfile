FROM ubuntu:22.04

ENV TZ="UTC"
ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y ca-certificates curl rsync \
    && rm -rf /var/lib/apt/lists/ \
    && groupadd app \
    && useradd --gid app --shell /bin/bash --create-home app

RUN mkdir -p /app /startup/root /startup/app
WORKDIR /app
VOLUME ["/app"]

COPY entry.sh /

ENTRYPOINT ["/entry.sh"]
