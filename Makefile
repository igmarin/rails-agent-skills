IMAGE_NAME      ?= igmarin/rails-agent-skills-mcp
GHCR_IMAGE      ?= ghcr.io/$(IMAGE_NAME)
DOCKER_HUB_IMAGE ?= docker.io/$(IMAGE_NAME)
VERSION         ?= latest

.PHONY: docker-build docker-publish-dockerhub docker-publish-ghcr docker-publish-all docker-login-ghcr help

docker-build:
	docker build -t $(IMAGE_NAME):$(VERSION) .

docker-publish-dockerhub:
	docker tag $(IMAGE_NAME):$(VERSION) $(DOCKER_HUB_IMAGE):$(VERSION)
	docker push $(DOCKER_HUB_IMAGE):$(VERSION)

docker-login-ghcr:
	@echo "Authenticating to ghcr.io..."
	@docker login ghcr.io || (echo "Failed to log in to ghcr.io. Generate a token at https://github.com/settings/tokens (read:packages, write:packages)" && exit 1)

docker-publish-ghcr: docker-login-ghcr
	docker tag $(IMAGE_NAME):$(VERSION) $(GHCR_IMAGE):$(VERSION)
	docker push $(GHCR_IMAGE):$(VERSION)

docker-publish-all: docker-publish-dockerhub docker-publish-ghcr

help:
	@grep -E '^[a-zA-Z_-]+:' $(MAKEFILE_LIST) | sort | awk -F ':' '{printf "  %-35s\n", $$1}'
