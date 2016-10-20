all:
	docker-compose build
	docker push yurifl/php-image:latest

build:
	docker-compose build

push.image:
	docker push yurifl/php-image:latest
