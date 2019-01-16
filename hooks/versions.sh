#!/bin/bash

export VARS='
BASE_IMAGE=openjdk:11-jdk GRADLE_VERSION=5.1 BASE_IMAGE_TAG="openjdk-11-gradle-5.1"
BASE_IMAGE=openjdk:8-jdk GRADLE_VERSION=5.1 BASE_IMAGE_TAG="openjdk-8-gradle-5.1"
BASE_IMAGE=openjdk:8-jdk GRADLE_VERSION=4.10 BASE_IMAGE_TAG="openjdk-8-gradle-4.10"
BASE_IMAGE=openjdk:11-jdk GRADLE_VERSION=4.10 BASE_IMAGE_TAG="openjdk-11-gradle-4.10"
'
