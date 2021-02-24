CIRCLE_BRANCH ?= latest
TAIGA_FRONT_TAG ?= 6.0.5
TAIGA_BACK_TAG ?= 6.0.5

BUILD_GITHUB_REPO ?= https://github.com/carneirofc/taiga-contrib-openid-auth

LABELS += --label taiga.plugin.openid=""
LABELS += --label taiga.plugin.openid.repo="$(BUILD_GITHUB_REPO)"

BUILD_ARGS += --build-arg BUILD_GITHUB_REPO="$(BUILD_GITHUB_REPO)"
BUILD_ARGS += --build-arg TAIGA_BACK_TAG="$(TAIGA_BACK_TAG)"
BUILD_ARGS += --build-arg TAIGA_FRONT_TAG="$(TAIGA_FRONT_TAG)"
DOCKER_BUILD_OPTS = $(LABELS) $(BUILD_ARGS)

DOCKER_REGISTRY ?= docker.io
DOCKER_USER_GROUP ?= carneirofc
DOCKER_IMAGE_PREFIX = $(DOCKER_REGISTRY)/$(DOCKER_USER_GROUP)

all: clean build

clean:
	docker system prune --filter "label=$(LABEL)" --all --force

build: build-js build-front build-back
build-js:
	cd front && npm install && npm run build
build-front:
	docker build docker/front $(DOCKER_BUILD_OPTS) -t $(DOCKER_IMAGE_PREFIX)/taiga-front-openid:$(CIRCLE_BRANCH)
	docker build docker/front $(DOCKER_BUILD_OPTS) -t $(DOCKER_IMAGE_PREFIX)/taiga-front-openid:$(TAIGA_FRONT_TAG)

build-back:
	docker build docker/back $(DOCKER_BUILD_OPTS) -t $(DOCKER_IMAGE_PREFIX)/taiga-back-openid:$(CIRCLE_BRANCH)
	docker build docker/back $(DOCKER_BUILD_OPTS) -t $(DOCKER_IMAGE_PREFIX)/taiga-back-openid:$(TAIGA_BACK_TAG)
	
publish:
	docker push $(DOCKER_IMAGE_PREFIX)/taiga-back-openid:$(CIRCLE_BRANCH)
	docker push $(DOCKER_IMAGE_PREFIX)/taiga-back-openid:$(TAIGA_BACK_TAG)
	docker push $(DOCKER_IMAGE_PREFIX)/taiga-front-openid:$(CIRCLE_BRANCH)
	docker push $(DOCKER_IMAGE_PREFIX)/taiga-front-openid:$(TAIGA_FRONT_TAG)
