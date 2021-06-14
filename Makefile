PORT := 8080
REGION := fr-par
REGISTRY_ENDPOINT := rg.$(REGION).scw.cloud
REGISTRY_NAMESPACE := osp-internal-tools
NOTION_URL := "https://www.notion.so/opensourcepolitics"
IMAGE_NAME := ask_notion
VERSION := latest
TAG := $(REGISTRY_ENDPOINT)/$(REGISTRY_NAMESPACE)/$(IMAGE_NAME):$(VERSION)

local-run:
	ROCKET_SECRET_TOKEN=$(ROCKET_SECRET_TOKEN) NOTION_URL=$(NOTION_URL) ROCKET_API_TOKEN=$(ROCKET_API_TOKEN) ROCKET_API_ID=$(ROCKET_API_ID) PORT=$(PORT) NOTION_API_KEY=$(NOTION_API_KEY) crystal run src/app.cr

local-build:
	crystal build -p src/app.cr -o dist/app

build:
	docker build . --compress --tag $(TAG)

run:
	docker run -it -e PORT=$(PORT) -e NOTION_URL=$(NOTION_URL) -e ROCKET_API_ID=$(ROCKET_API_ID) -e ROCKET_API_TOKEN=$(ROCKET_API_TOKEN) -e NOTION_API_KEY=$(NOTION_API_KEY) -e ROCKET_SECRET_TOKEN=$(ROCKET_DUMMY_TOKEN) -p $(PORT):$(PORT) --rm $(TAG)

push:
	docker push $(TAG)

deploy:
	@make build
	@make push

login:
	docker login $(REGISTRY_ENDPOINT) -u userdoesnotmatter -p $(TOKEN)

make test:
	curl localhost:$(PORT)

lint:
	@echo "Linting files..."
	crystal tool format
	yamllint .

test-server:
	LOCALES_DIR="**/spec/src/locales" crystal run src/app.cr

spec:
	@echo "Running tests..."
	cd src/ && crystal spec
