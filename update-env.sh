#!/usr/bin/env bash

url=https://nextcloud.com/install/

src=$(curl -sfL ${url} | grep -oP "Latest release:\s+\K[^\s]*")
ver=$(echo ${src} | sed "s/<\/*strong>//g")

cat <<EOF > ${PWD}/.env
# Default target OS and variant
TARGET_OS=alpine
TARGET_OS_VERSION=3.21
TARGET_VARIANT=fpm

# Nextcloud versioning
VERSION_MAJOR=${ver%%.*}
VERSION_MINOR=$(: "${ver#*.}"; echo ${_%.*})
VERSION_REVISION=${ver##*.}

# Compose files
COMPOSE_FILE="\${PWD}/build.yml:\${PWD}/updates.yml"
EOF

exit 0
