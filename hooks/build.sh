#!/bin/bash

TAG="emundo/docker-compose-openjdk-node-gradle:${IMAGE_TAG}"

echo 'Lade alle verfügbaren Gradle-Versionen'
PAGE_URL='https://services.gradle.org/versions/all'
PAGE_DATA="$(curl -fsSL "$PAGE_URL")"
# Parse alle Release-Versionen aus JSON-String
allGradleVersions=()
allGradleVersions=( $(
		echo "$PAGE_DATA" \
			| grep -oP '(?<="version" : ")[\d.]+(?=",)'
))

# Suche die höchste Minor-Version die passt
FULL_GRADLE_VERSION="$(
		echo "${allGradleVersions[@]}" | xargs -n1 \
			| grep -E "^${GRADLE_VERSION}(.*)$" \
            | sort -V \
			| tail -1
	    )" || true
echo "Benutze Gradle ${FULL_GRADLE_VERSION}"
echo "Benutze Base Image ${BASE_IMAGE}"

docker build . \
    -t "$TAG" \
    --build-arg base_image=$BASE_IMAGE \
    --build-arg gradle_version=$FULL_GRADLE_VERSION

IMAGE_ID=$(docker images $TAG --format "{{.ID}}")


for tag in ${EXTRA_TAGS//;/$'\n'}
do
    echo $tag
    docker tag $IMAGE_ID "emundo/docker-compose-openjdk-node-gradle:${tag}"
done

