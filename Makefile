

install:
	composer install -n
	mkdir -p .render

build: generate-docker build-docker

generate-docker:
	bin/console app:docker:generate

generate-matrix:
	bin/console app:gha:matrix

build-docker:
	./scripts/build.sh

build-one-docker:
	./scripts/build_one.sh
