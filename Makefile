SHELL := /bin/bash

registry_id = 304987907870

build:
	docker-compose build

start:
	docker-compose up

shell:
	docker-compose run app bash

restart:
	docker-compose restart app

stop:
	docker-compose down

docker-login:
	aws --profile jetstream ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin $(registry_id).dkr.ecr.eu-west-1.amazonaws.com

ecr-image-push:
	docker build -t cachet .
	docker tag cachet:latest $(registry_id).dkr.ecr.eu-west-1.amazonaws.com/cachet:latest
	docker push $(registry_id).dkr.ecr.eu-west-1.amazonaws.com/cachet:latest

clean:
	docker-compose kill
	docker-compose down
	docker image prune -f
	docker network prune -f
	docker volume prune -f
