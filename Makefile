
BUILDAH		=	$(shell which buildah)

.PHONY: container
container:
	${BUILDAH} bud . -t ghcr.io/endgrid/mattellite:latest