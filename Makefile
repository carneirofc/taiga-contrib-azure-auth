DATE = $(shell date -I)
HASH = $(shell git rev-parse --short HEAD)

TAIGA_FRONT_TAG ?= 6.0.5
TAIGA_BACK_TAG ?= 6.0.5

BUILD_GITHUB_REPO ?= https://github.com/carneirofc/taiga-contrib-azure-auth
BUILD_GITHUB_BASE ?= https://github.com/robrotheram/taiga-contrib-openid-auth

LABELS += --label taiga.plugin.azure=""
LABELS += --label taiga.plugin.azure.repo="$(BUILD_GITHUB_REPO)"
LABELS += --label taiga.plugin.azure.commit="$(HASH)"
LABELS += --label taiga.plugin.azure.basedOn="$(BUILD_GITHUB_BASE)"

BUILD_ARGS += --build-arg BUILD_GITHUB_REPO="$(BUILD_GITHUB_REPO)"
BUILD_ARGS += --build-arg TAIGA_BACK_TAG="$(TAIGA_BACK_TAG)"
BUILD_ARGS += --build-arg TAIGA_FRONT_TAG="$(TAIGA_FRONT_TAG)"

DOCKER_BUILD_OPTS = $(LABELS) $(BUILD_ARGS) --no-cache

DOCKER_REGISTRY ?= docker.io
DOCKER_USER_GROUP ?= carneirofc
DOCKER_IMAGE_PREFIX = $(DOCKER_REGISTRY)/$(DOCKER_USER_GROUP)

all: clean build

clean:
	docker system prune --filter "label=$(LABEL)" --all --force
	docker image rm --force $(DOCKER_IMAGE_PREFIX)/taiga-back-azure:$(TAIGA_BACK_TAG)-$(DATE)
	docker image rm --force $(DOCKER_IMAGE_PREFIX)/taiga-front-azure:$(TAIGA_FRONT_TAG)-$(DATE)

build: build-js build-docker
build-js:
	cd front && npm install && npm run build
build-docker: build-front build-back
build-front:
	docker build docker/front $(DOCKER_BUILD_OPTS) --tag $(DOCKER_IMAGE_PREFIX)/taiga-front-azure:$(TAIGA_FRONT_TAG)-$(DATE)

build-back:
	docker build docker/back $(DOCKER_BUILD_OPTS) --tag $(DOCKER_IMAGE_PREFIX)/taiga-back-azure:$(TAIGA_BACK_TAG)-$(DATE)
	
publish:
	docker push $(DOCKER_IMAGE_PREFIX)/taiga-back-azure:$(TAIGA_BACK_TAG)-$(DATE)
	docker push $(DOCKER_IMAGE_PREFIX)/taiga-front-azure:$(TAIGA_FRONT_TAG)-$(DATE)
