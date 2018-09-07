#!/usr/bin/env bash
# This simple script tests a few common cases for matching version pattern against artifact.
# Note that it depends on a live OSS repository and may start failing at some point if release artifacts are deleted.

. ./update-service.sh sourced

readonly RELEASE_REPO=https://mvnrepo.cantara.no/content/repositories/releases
readonly SNAPSHOT_REPO=https://mvnrepo.cantara.no/content/repositories/snapshots
readonly GROUP_ID=net/whydah/token
readonly ARTIFACT_ID=SecurityTokenService
readonly DELAY=
readonly USERNAME=
readonly PASSWORD=

echoerr() { echo "$@" 1>&2; }

find_artifact_test() {
    FAILED=false

    find_artifact "2.4.*" jarfile url
    if [[ "$jarfile" != "SecurityTokenService-2.4.19.jar" && "$url" != "https://mvnrepo.cantara.no/content/repositories/releases/net/whydah/token/SecurityTokenService/2.4.19/SecurityTokenService-2.4.19.jar" ]]; then
        echoerr "EXPECTED:  SecurityTokenService-2.4.19.jar - https://mvnrepo.cantara.no/content/repositories/releases/net/whydah/token/SecurityTokenService/2.4.19/SecurityTokenService-2.4.19.jar"
        echoerr "ACTUAL:    $jarfile - $url"
        FAILED=true
    fi

    find_artifact "2.4.19" jarfile url
    if [[ "$jarfile" != "SecurityTokenService-2.4.19.jar" && "$url" != "https://mvnrepo.cantara.no/content/repositories/releases/net/whydah/token/SecurityTokenService/2.4.19/SecurityTokenService-2.4.19.jar" ]]; then
        echoerr "EXPECTED:  SecurityTokenService-2.4.19.jar - https://mvnrepo.cantara.no/content/repositories/releases/net/whydah/token/SecurityTokenService/2.4.19/SecurityTokenService-2.4.19.jar"
        echoerr "ACTUAL:    $jarfile - $url"
        FAILED=true
    fi

    find_artifact "SNAPSHOT" jarfile url
    echo "$URL"
    if [[ ! "$url" == *SNAPSHOT*.jar ]]; then
        echoerr "EXPECTED:  to contain SNAPSHOT"
        echoerr "ACTUAL:    $jarfile - $url"
        FAILED=true
    fi

    # Find release with classifier
    CLASSIFIER=jar-with-dependencies
    find_artifact "2.4.19" jarfile url
    if [[ "$jarfile" != "SecurityTokenService-2.4.19-jar-with-dependencies.jar" && "$url" != "https://mvnrepo.cantara.no/content/repositories/releases/net/whydah/token/SecurityTokenService/2.4.19/SecurityTokenService-2.4.19-jar-with-dependencies.jar" ]]; then
        echoerr "EXPECTED:  SecurityTokenService-2.4.19-jar-with-dependencies.jar - https://mvnrepo.cantara.no/content/repositories/releases/net/whydah/token/SecurityTokenService/2.4.19/SecurityTokenService-2.4.19-jar-with-dependencies.jar"
        echoerr "ACTUAL:    $jarfile - $url"
        FAILED=true
    fi

    # Find snapshot with classifier
    find_artifact "SNAPSHOT" jarfile url
    if [[ ! "$url" == *SNAPSHOT*.jar ]] && [[ ! "$url" == *$CLASSIFIER ]]; then
        echoerr "EXPECTED:  to contain SNAPSHOT"
        echoerr "ACTUAL:    $jarfile - $url"
        FAILED=true
    fi

    if [[ "$FAILED" = true ]]; then
        echoerr "Test failed!"
        exit 1
    fi
}

find_artifact_test