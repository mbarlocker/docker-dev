#!/bin/bash

trap 'exit 0' 1 2 3 6 15

USER=app
GROUP=app

if [[ -z "${DOCKER_UID}" ]]; then
	echo 'You need to set DOCKER_UID before you run this container'
	echo 'See https://github.com/mbarlocker/docker-typescript-dev for more details'
	exit 1
fi

if [[ -z "${DOCKER_GID}" ]]; then
	echo 'You need to set DOCKER_GID before you run this container'
	echo 'See https://github.com/mbarlocker/docker-typescript-dev for more details'
	exit 1
fi

BASE_UID="$(id -u "${USER}" 2>/dev/null)"
BASE_GID="$(getent group "${GROUP}" 2>/dev/null | awk -F':' '{ print $3; }')"

if [[ "${BASE_UID}" != "${DOCKER_UID}" ]]; then
	usermod -u "${DOCKER_UID}" "${USER}"
	find /home -user "${BASE_UID}" -exec chown -h "${USER}" {} \;
fi

if [[ "${BASE_GID}" != "${DOCKER_GID}" ]]; then
	groupmod -g "${DOCKER_GID}" "${GROUP}"
	find /home -group "${BASE_GID}" -exec chgrp -h "${GROUP}" {} \;
fi

( cd / && run-parts /startup/root )

exec su -l -g "${GROUP}" "${USER}" <<EOF
( cd / && run-parts /startup/app )
EOF
