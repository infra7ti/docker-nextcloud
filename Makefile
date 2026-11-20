SHELL := /usr/bin/env bash

TARGET_OS      ?= alpine
TARGET_VARIANT ?= fpm
COMPOSE_FILE   ?= build.yml
BUILD_FLAGS    ?= --push

# Get latest 3 Nextcloud majors with their minors/patches
define GET_RELEASES
curl -sL -A "Mozilla/5.0" https://download.nextcloud.com/server/releases/ \
	| grep -oE 'nextcloud-[0-9]+\.[0-9]+\.[0-9]+\.zip' \
	| sed -E 's/^nextcloud-(.*)\.zip$$/\1/' \
	| sort -Vr \
	| awk -F. '!seen[$$1]++' \
	| head -n 3
endef

.PHONY: all stable production legacy info _build

info:
	@echo "Retrieving releases info from https://nextcloud.com..."
	@RELEASES=$$($(GET_RELEASES)); \
	if [ -z "$$RELEASES" ]; then \
		echo "Error: Can't read release info from https://nextcloud.com" >&2; \
		exit 1; \
	fi; \
	echo "Detected Channels:"; \
	echo "$$RELEASES" | awk 'NR==1{print "  stable     -> " $$0} NR==2{print "  production -> " $$0} NR==3{print "  legacy     -> " $$0}'

all:
	@$(MAKE) legacy LATEST=0
	@$(MAKE) production LATEST=0
	@$(MAKE) stable LATEST=1

stable: LATEST ?= 1
stable:
	@VER=$$($(GET_RELEASES) | sed -n '1p'); \
	$(MAKE) _build VER="$$VER" LATEST=$(LATEST)

production: LATEST ?= 0
production:
	@VER=$$($(GET_RELEASES) | sed -n '2p'); \
	$(MAKE) _build VER="$$VER" LATEST=$(LATEST)

legacy: LATEST ?= 0
legacy:
	@VER=$$($(GET_RELEASES) | sed -n '3p'); \
	$(MAKE) _build VER="$$VER" LATEST=$(LATEST)

_build:
	@if [ -z "$(VER)" ]; then echo "Error: Nextcloud version not found." >&2; exit 1; fi
	@IFS='.' read -r MAJOR MINOR REV <<< "$(VER)"; \
	if [ "$(LATEST)" = "1" ]; then \
		PROFILE="build-latest"; \
		SERVICE="builds-latest"; \
	else \
		PROFILE="build"; \
		SERVICE="builds"; \
	fi; \
	echo "=========================================================="; \
	echo "Building Nextcloud $(VER) | Service: $${SERVICE} (LATEST=$(LATEST))"; \
	echo "=========================================================="; \
	PWD="$(CURDIR)" \
	TARGET_OS="$(TARGET_OS)" \
	TARGET_VARIANT="$(TARGET_VARIANT)" \
	VERSION_MAJOR="$${MAJOR}" \
	VERSION_MINOR="$${MINOR}" \
	VERSION_REVISION="$${REV}" \
	docker compose --profile $${PROFILE} build $(BUILD_FLAGS) $${SERVICE}
