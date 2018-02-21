#!/bin/bash

readonly YELLOW='\033[0;33m'
readonly NC='\033[0m' # clear colour

# If this code hasn't been commited yet, use the current date
git diff --exit-code . 1>/dev/null 2>/dev/null
if [ "$?" -ne "0" ]; then
    echo -e "${YELLOW}WARNING: You have uncommitted changes, using current date${NC}" >&2
    readonly IMAGE_DATE=$(date '+%Y%m%d-%H%M')
else
    readonly IMAGE_DATE=$(git log -1 --date=iso $(git rev-list -1 HEAD -- .) --format=%ci | awk '{ print $1 " " $2 }' | tr -d '-' | cut -d ':' -f 1,2 | tr ' ' '-' | tr -d ':')
fi

echo $IMAGE_DATE