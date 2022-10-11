#!/bin/sh
if ! docker buildx ls | grep -q '^multiplatform'; then
    docker buildx create --name multiplatform
fi
docker buildx use multiplatform
docker buildx inspect --bootstrap
docker buildx build --platform linux/amd64,linux/arm64/v8 -t flowchartsman/bitmap-font-vector-build:latest --push .
