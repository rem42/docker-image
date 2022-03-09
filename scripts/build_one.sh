#!/bin/bash

RENDER_DIR="./.render/"
repo=$1
type=$2
version=$3
variant=$4
prName=

if test "$PR_NUMBER"
then
  prName="-pr-$PR_NUMBER"
fi

if test -z "$variant"
then
  path="$RENDER_DIR/$type.$version.Dockerfile"
  tagName="$repo:$version$prName"
else
  path="$RENDER_DIR/$type.$version.$variant.Dockerfile"
  tagName="$repo:$version-$variant$prName"
fi

echo "$path"
echo "$tagName"

if [ ! -f "$path" ]
then
  echo "file not found"
  exit 0
fi

export DOCKER_BUILDKIT=0
export COMPOSE_DOCKER_CLI_BUILD=0

if test "$PR_NUMBER"
then
  docker buildx build --pull --push --platform linux/amd64,linux/arm64,darwin/amd64 --tag "$tagName" --label "$tagName" --file "$path" -o type=registryy -
else
  docker buildx build --pull --push --platform linux/amd64,linux/arm64,darwin/amd64 --tag "$tagName-latest" --tag "$tagName-$(date +'%Y%m%d')" --label "$tagName-$(date +'%Y%m%d')" --file "$path" -o type=registry -
fi
