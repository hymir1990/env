#!/bin/bash

source ./docker_utils.sh
if ! dockerd_running; then exit 1; fi

boot_container

docker exec -ti $CONTAINER_NAME bash -l -c "cd src/ && ${SCRIPT} ${PARAMS}"