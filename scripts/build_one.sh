#!/bin/bash

RENDER_DIR="./.render/"
repo=$1
type=$2
version=$3
variant=$4

if test -z "$variant"
then
  path="$RENDER_DIR/$type.$version.Dockerfile"
  tagName="$repo:$version"
else
  path="$RENDER_DIR/$type.$version.$variant.Dockerfile"
  tagName="$repo:$version-$variant"
fi

echo "$path"
echo "$tagName"

if [ -f "$path" ]
then
  docker build --pull -t "$tagName-latest" -t "$tagName-$(date +'%Y%m%d')" --label "$tagName-$(date +'%Y%m%d')" - < "$path"
  docker push "$repo" --all-tags
fi
