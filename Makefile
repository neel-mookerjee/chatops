AWS_ACCOUNT	:= "12345678901"
IMAGE_NAME	:= "chatbot"
REPOSITORY_NAME	:= "$(IMAGE_NAME)"
ECR_REPOSITORY	:= "$(AWS_ACCOUNT).dkr.ecr.us-west-2.amazonaws.com/$(REPOSITORY_NAME)"

check-var = $(if $(strip $($1)),,$(error var for "$1" is empty))

default: help

require_tag:
	$(call check-var,tag)

go/compile: 			## compile go programs
						@CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o bin/main ./go

docker/tag/list:		## list the existing tagged images
						@aws ecr list-images --registry-id $(AWS_ACCOUNT) --repository-name $(REPOSITORY_NAME) --filter tagStatus=TAGGED | jq -M -r '.imageIds|.[]|.imageTag'

docker/build:			validate_tag ## build and tag the Docker image. vars:tag
						@docker build -t $(IMAGE_NAME) .
						@docker tag $(REPOSITORY_NAME) $(ECR_REPOSITORY):$(tag)

validate_tag:			require_tag
						#@aws ecr list-images --registry-id $(AWS_ACCOUNT) --repository-name $(REPOSITORY_NAME) --filter tagStatus=TAGGED | jq -M -r '.imageIds|.[]|.imageTag' | tr '\n' ' ' | grep -q -v $(tag)[^-] || { echo "error using the tag"; exit 1;}

docker/push:			validate_tag ## push the Docker image to ECR. vars:tag
						@aws ecr get-login --region us-west-2 --no-include-email | sh -
						@docker push $(ECR_REPOSITORY):$(tag)

helm/install:           ## Deploy stack into kubernetes.
	                    @helm install --name chatbot ./chart

helm/delete:            ## delete stack from reference. vars: stack
	                    @helm delete --purge chatbot

deploy:                 require_tag ## Compiles, builds and deploys a stack for a tag. vars: tag
						@CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o bin/main ./go
						@docker build -t $(IMAGE_NAME) .
						@docker tag $(REPOSITORY_NAME) $(ECR_REPOSITORY):$(tag)
						@aws ecr get-login --region us-west-2 --no-include-email | sh -
						@docker push $(ECR_REPOSITORY):$(tag)
	                    @helm install --name chatbot ./chart

redeploy:               require_tag ## Compiles, builds and deploys a stack for a tag. vars: tag
						@CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o bin/main ./go
						@docker build -t $(IMAGE_NAME) .
						@docker tag $(REPOSITORY_NAME) $(ECR_REPOSITORY):$(tag)
						@aws ecr get-login --region us-west-2 --no-include-email | sh -
						@docker push $(ECR_REPOSITORY):$(tag)
	                    @helm delete chatbot
	                    @helm install --name chatbot ./chart

help:					## this helps
						@awk 'BEGIN {FS = ":.*?## "} /^[\/a-zA-Z_-]+:.*?## / {sub("\\\\n",sprintf("\n%22c"," "), $$2);printf "\033[36mchatbot \033[0m%-16s %s\n", $$1, $$2}' $(MAKEFILE_LIST)
