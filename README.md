# Docker Dev

[![Docker Image Publish](https://github.com/mbarlocker/docker-dev/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/mbarlocker/docker-dev/actions/workflows/docker-publish.yml)

## Contents

This repo builds a Docker container.

The resultant container can be used to develop apps locally. 

One thing that makes this container special is that it takes care to preserve ownership and permissions
between the host and the container. If you're developing as myuser (uid 1000 gid 1000), the container
will use the same uid and gid. This means no weird ownership or permission issues.

## Usage

First, to get the permissions to work, you have to update your `.bashrc` or equivalent. Add these lines to the bottom of that file.

```bash
export DOCKER_UID=$(id -u)
export DOCKER_GID=$(id -g)
```

If you have any special programs, installs, or anything that needs to be done as root, add a file to `/startup/root`.
The name of the file must follow a format `<priority>-<name>` and be executable. For example, in `/startup/root/000-nvm`:
```bash
#!/bin/bash

if ! command -v nvm &>/dev/null; then
  curl -o /opt/install.sh "https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh"
  chmod +x /opt/install.sh

  # the app uid and app gid are part of the base docker image
  su -g app app -l /opt/install.sh

  grep NVM_DIR /home/app/.bashrc > /home/app/.bashnvm
  chown app:app /home/app/.bashnvm
  rm -f /opt/install.sh
fi
```

There is another directory for running as the app user (with matching UID and GID). This directory is `/startup/app`
and has the same format and executable requirements. For example, in `/startup/app/999-run`

```bash
#!/bin/bash

# this sets up NVM
source ~/.bashnvm
nvm -v

# go to your app
cd /app

# install and use node based on .nvmrc file
nvm install
nvm use
node -v

yarn install
exec yarn dev
```

Finally, use `docker` or `docker compose` to put everything in place. This `docker-compose.yaml` is placed in the root of your application.

```yaml
services:
  myapp:
    image: mbarlocker/docker-dev:latest
    environment:
      DOCKER_UID: "${DOCKER_UID}"
      DOCKER_GID: "${DOCKER_GID}"
    volumes:
      - .:/app
      - ./docker/startup/root:/startup/root
      - ./docker/startup/app:/startup/app
```

## Docker Hub

Find the docker image on Docker Hub: [Docker Dev](https://hub.docker.com/r/mbarlocker/docker-dev)

![Image pushed to Docker Hub](https://raw.githubusercontent.com/mbarlocker/docker-dev/main/images/image-pushed-to-docker-hub.png)

## License

[MIT](https://choosealicense.com/licenses/mit/)
