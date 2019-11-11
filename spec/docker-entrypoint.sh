#!/bin/sh

DOCKER_SOCKET=/var/run/docker.sock
DOCKER_GROUP=docker
USER=tester

if [ -S ${DOCKER_SOCKET} ]; then
  DOCKER_GID=$(stat -c '%g' ${DOCKER_SOCKET})
  addgroup -g ${DOCKER_GID} ${DOCKER_GROUP}
  addgroup ${USER} ${DOCKER_GROUP}
fi

su-exec ${USER} rspec "$@"
