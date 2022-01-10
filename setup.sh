#!/bin/bash

/bin/bash ./uninstall.sh

source ./docker_utils.sh
if ! dockerd_running; then exit 1; fi

build_image