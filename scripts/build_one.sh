#!/bin/bash

RENDER_DIR="./.render/"
version=$1
variant=$2

path="$RENDER_DIR/php.$version.$variant.Dockerfile"
if [ -f "$path" ]
then
  tagName="rem42/circleci-docker-php:$version-$variant"
  docker build --pull -t "$tagName-latest" -t "$tagName-$(date +'%Y%m%d')" --label "$tagName-$(date +'%Y%m%d')" - < "$path"
  docker push rem42/circleci-docker-php --all-tags
fi
