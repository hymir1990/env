#!/bin/bash

source ./docker_utils.sh
if ! dockerd_running; then exit 1; fi

stop_container
remove_container
remove_image

