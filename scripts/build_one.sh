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

if test "$PR_NUMBER"
then
  docker build --pull -t "$tagName" --label "$tagName" - < "$path"
  docker push "$repo" --all-tags
else
  docker build --pull -t "$tagName-latest" -t "$tagName-$(date +'%Y%m%d')" --label "$tagName-$(date +'%Y%m%d')" - < "$path"
  docker push "$repo" --all-tags
fi
