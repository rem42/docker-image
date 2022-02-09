#!/bin/bash

RENDER_DIR="./.render/"
repo=$1
version=$2
variant=$3

path="$RENDER_DIR/php.$version.$variant.Dockerfile"
if [ -f "$path" ]
then
  tagName="$repo:$version-$variant"
  docker build --pull -t "$tagName-latest" -t "$tagName-$(date +'%Y%m%d')" --label "$tagName-$(date +'%Y%m%d')" - < "$path"
  docker push "$repo" --all-tags
fi
