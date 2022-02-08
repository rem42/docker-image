#!/bin/bash

RENDER_DIR="./.render/"
version=$1
variant=$2

path="$RENDER_DIR/yarn.$version.$variant.Dockerfile"
if [ -f "$path" ]
then
  tagName="rem42/docker-yarn:$version-$variant"
  docker build --pull -t "$tagName-latest" -t "$tagName-$(date +'%Y%m%d')" --label "$tagName-$(date +'%Y%m%d')" - < "$path"
  docker push rem42/docker-yarn --all-tags
fi
