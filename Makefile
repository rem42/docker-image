

install:
	composer install -n
	mkdir -p .render

build: generate-docker build-docker

generate-docker:
	bin/console app:docker:generate

build-docker:
	./scripts/build.sh
