#!/bin/bash
set -Eeuo pipefail

trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 131' QUIT
trap 'exit 143' TERM

APP_USER=app
APP_GROUP=app

: "${DOCKER_UID:?You need to set DOCKER_UID before you run this container}"
: "${DOCKER_GID:?You need to set DOCKER_GID before you run this container}"

[[ "${DOCKER_UID}" =~ ^[0-9]+$ ]] || { echo "DOCKER_UID must be numeric"; exit 1; }
[[ "${DOCKER_GID}" =~ ^[0-9]+$ ]] || { echo "DOCKER_GID must be numeric"; exit 1; }

BASE_UID="$(id -u "${APP_USER}")"
BASE_GID="$(getent group "${APP_GROUP}" | awk -F: '{print $3}')"

if [[ "${BASE_UID}" != "${DOCKER_UID}" ]]; then
	usermod -u "${DOCKER_UID}" "${APP_USER}"
	find /home -uid "${BASE_UID}" -exec chown -h "${APP_USER}" {} +
fi

if [[ "${BASE_GID}" != "${DOCKER_GID}" ]]; then
	groupmod -g "${DOCKER_GID}" "${APP_GROUP}"
	find /home -gid "${BASE_GID}" -exec chgrp -h "${APP_GROUP}" {} +
fi

if [[ -d /startup/root ]]; then
	( cd / && run-parts --exit-on-error /startup/root )
fi

exec su -l -g "${APP_GROUP}" "${APP_USER}" -c 'cd / && run-parts --exit-on-error /startup/app'
