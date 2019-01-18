#!/bin/bash

TAG="emundo/docker-compose-openjdk-node-gradle:${BASE_IMAGE_TAG}"

echo 'Lade alle verfügbraen Gradle Versionen'
PAGE_URL='https://services.gradle.org/versions/all'
PAGE_DATA="$(curl -fsSL "$pageUrl")"
# Parse alle Release Versionen aus json String
allGradleVersions=()
allGradleVersions=( $(
		echo "$PAGE_DATA" \
			| grep -oP '(?<="version" : ")[\d.]+(?=",)'
))

# Suche die höchste Minor Version die passt
FULL_GRADLE_VERSION="$(
		echo "${allGradleVersions[@]}" | xargs -n1 \
			| grep -E "^${GRADLE_VERSION}(.*)$" \
            | sort -V \
			| tail -1
	    )" || true
echo "Benutze Gradle ${FULL_GRADLE_VERSION}"
echo "Benutze Base Image ${BASE_IMAGE}"

docker build . \
    --no-cache \
    -t "$TAG" \
    --build-arg base_image=$BASE_IMAGE \
    --build-arg gradle_version=$FULL_GRADLE_VERSION

image_id=$(docker images $TAG --format "{{.ID}}")

