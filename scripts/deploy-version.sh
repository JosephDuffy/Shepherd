#!/bin/bash

if [ $# -ne 1 ]; then
    echo "A single argument specifying the version must be provided"
    exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
    echo "Git repo must be clean"
    exit 1
fi

VERSION=$1
NORMALISED_VERSION=${VERSION#"v"}

if [ "$NORMALISED_VERSION" = "$VERSION" ]; then
    echo "Version should start with a \"v\""
    exit 1
fi

SCRIPT_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source ${SCRIPT_DIRECTORY}/update-version.sh "v$NORMALISED_VERSION"

git tag "$NORMALISED_VERSION"
git push origin "$NORMALISED_VERSION"
