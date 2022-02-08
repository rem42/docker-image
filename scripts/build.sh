#!/bin/bash

RENDER_DIR="./.render/"
CONFIG_FILE="./config/docker.json"

images=$(jq -r '.docker.images[].name' $CONFIG_FILE)

i=0
for image in $images; do
  name=$(jq -r ".docker.images[$i].name" $CONFIG_FILE)
  versions=$(jq -r ".docker.images[$i].versions[]" $CONFIG_FILE)
  variants=$(jq -r ".docker.images[$i].variants[]" $CONFIG_FILE)

  for version in $versions;
  do
    for variant in $variants;
    do
      path="$RENDER_DIR/$name.$version.$variant.Dockerfile"
      if [ -f "$path" ]
      then
        tagName="rem42/circleci-docker-php:$version-$variant"
        docker build -t "$tagName-latest" -t "$tagName-$(date +'%Y%m%d')" --label "$tagName-$(date +'%Y%m%d')" - < "$path"
        docker push rem42/circleci-docker-php --all-tags
      fi
    done
  done
  ((i=i+1))
done
