#!/bin/bash

PWD=$(pwd)
ENVIRONMENT_FILE=$PWD/env.conf

source $ENVIRONMENT_FILE

function dockerd_running() {
   if [ "$(systemctl show --property ActiveState docker)" != "ActiveState=active" ]; then 
      echo "Dockerd must be running."
      return $(false)
   fi
   return $(true)
}

function build_image() {
   date_str=$(date '+%Y%m%d_%H:%M')
   docker build -t "$IMAGE_NAME:$IMAGE_TAG" --progress plain  -f $DOCKER_FILE_NAME .
   #>"$PWD/$date_str.log" 2>"$PWD/$date_str.err"
}

function image_created() {
   if [ "$(docker image inspect --format="found" $IMAGE_NAME:$IMAGE_TAG 2>/dev/null)" == "found" ]; then
      return $(true)
   else
      return $(false)
   fi
}

function remove_image() {
   if image_created; then
      echo "Deleting image $IMAGE_NAME:$IMAGE_TAG ... "
      docker rmi --force $IMAGE_NAME:$IMAGE_TAG
      echo "Done"
   fi
}


function container_running() {
   if [ "$(docker container inspect -f '{{.State.Status}}' $CONTAINER_NAME 2> /dev/null )" == "running" ]; then 
      return $(true)
   else
      return $(false)
   fi
}

function stop_container() {
   if container_running; then
      echo "Stopping Container $CONTAINER_NAME ... "
      docker container stop $CONTAINER_NAME
      echo "Done."
   fi
}

function remove_container() {
   if container_running; then
      echo "Removing Container $CONTAINER_NAME ... "
      docker rm --force $CONTAINER_NAME
      echo "Done"
   fi
}

function boot_container() {
   if ! container_running; then
      docker run -d -i \
         --name  $CONTAINER_NAME \
         --mount type=bind,source=$HOME/s3/benchmarks/tpch/scripts,target=/benchmarks/tpch/scripts \
         --mount type=bind,source=$HOME/s3/benchmarks/tpch/results,target=/benchmarks/tpch/results \
         --mount type=bind,source=$HOME/s3/benchmarks/tpch/generated,target=/benchmarks/tpch/generated \
         --user=$USER_ID:$USER_GROUP \
         $IMAGE_NAME:$IMAGE_TAG
   fi
}