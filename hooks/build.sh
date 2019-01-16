#!/bin/bash

TAG="robertschreib/docker-compose-openjdk-node-gradle:${BASE_IMAGE_TAG}"


# Hole alle möglichen gradle release versionen
echo 'Lade alle verfügbraen Gradle Versionen'
pageUrl='https://services.gradle.org/versions/all'
page="$(curl -fsSL "$pageUrl")"
# Parse alle Release Versionen aus json String
allGradleVersions=()
allGradleVersions=( $(
		echo "$page" \
			| grep -oP '(?<="version" : ")[\d.]+(?=",)'
))
# Lade höchste Minor Version die passt
gradle_full_version="$(
		echo "${allGradleVersions[@]}" | xargs -n1 \
			| grep -E "^${GRADLE_VERSION}(.*)$" \
            | sort -V \
			| tail -1
	    )" || true
echo "Benutze Gradle ${gradle_full_version}"
echo "Benutzer Base Image ${BASE_IMAGE}"
set -x

docker build . \
    --no-cache \
    -t "$TAG" \
    --build-arg base_image=$BASE_IMAGE \
    --build-arg gradle_version=$gradle_full_version 

image_id=$(docker images $TAG --format "{{.ID}}")

