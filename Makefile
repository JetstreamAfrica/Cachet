SHELL := /bin/bash

registry_id = 256688911890

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
	aws --profile bitsika ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin $(registry_id).dkr.ecr.eu-west-1.amazonaws.com

ecr-image-push:
	docker build -t transaction-api .
	docker tag transaction-api:latest $(registry_id).dkr.ecr.eu-west-1.amazonaws.com/transaction-api:latest
	docker push $(registry_id).dkr.ecr.eu-west-1.amazonaws.com/transaction-api:latest

clean:
	docker-compose kill
	docker-compose down
	docker image prune -f
	docker network prune -f
	docker volume prune -f
