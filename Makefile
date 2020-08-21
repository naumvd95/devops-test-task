GIT_HOST = github.com
PWD := $(shell pwd)
GOPATH_DEFAULT := $(shell go env GOPATH)
export GOPATH ?= $(GOPATH_DEFAULT)
GOBIN_DEFAULT := $(GOPATH)/bin
export GOBIN ?= $(GOBIN_DEFAULT)
PATH := $(PATH):$(PWD)/bin:$(GOBIN)
VERBOSE :=
ifndef VERBOSE
GOFLAGS   :=
DEPFLAGS  :=
else
GOFLAGS   := "-v"
DEPFLAGS  := "-v"
endif
GOOS ?= $(shell go env GOOS)

$(GOBIN):
	echo "create gobin"
	mkdir -p $(GOBIN)
work: $(GOBIN)

#go tools
HAS_DEP := $(shell command -v dep;)
depend: work
ifndef HAS_DEP
	curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh
endif
	dep ensure $(DEPFLAGS)

depend-update:
	dep ensure -update $(DEPFLAGS)

#versioning
APP_VERSION ?= $(shell hack/get_version.sh)
GIT_REV := $(shell git rev-parse --short=7 HEAD)
version:
	@echo ${APP_VERSION}
 
# binaries
app-bin:
	GOOS=$(GOOS) go build $(GOFLAGS) \
		-o bin/ervcp \
		app/main.go

# images
REGISTRY := vnaumov
app-image-name:
	@echo $(REGISTRY)/ervcp:$(APP_VERSION)
app-image: app-bin
ifeq ($(GOOS),linux)
	TMPDIR="$$(mktemp -d)"; \
	cleanup () { rm -rf "$${TMPDIR}"; }; \
	trap cleanup EXIT; \
	cp -R bin/ervcp app/* "$${TMPDIR}"; \
	docker build -t $(REGISTRY)/ervcp:$(APP_VERSION) -f Dockerfile "$${TMPDIR}"
else
	$(error Please set GOOS=linux for building the image)
endif

DOCKER_USERNAME := vnaumov
DOCKER_PASSWORD :=
image-push:
	@echo "push images to $(REGISTRY)"
	docker login -u="$(DOCKER_USERNAME)" -p="$(DOCKER_PASSWORD)"
	docker push $(REGISTRY)/ervcp:$(APP_VERSION)

# infra image ops
INFRA_IMAGE := $(REGISTRY)/go-k8s-infra-ops:latest
infra-image:
	docker build -t $(INFRA_IMAGE) -f hack/Dockerfile .

# linters
dockerized-lint:
	docker run --rm \
	-v $(PWD):/go/src/github.com/naumvd95/devops-test-task \
	-w=/go/src/github.com/naumvd95/devops-test-task \
	$(INFRA_IMAGE) make VERBOSE=1 infra-lint

# local
lint:
	if golangci-lint run -v ./...; then \
	  :; \
	else \
	  code=$$?; \
	  echo "Looks like golangci-lint failed. You can try autofixes with 'make fix'."; \
	  exit $$code; \
	fi

infra-lint: lint
	helm lint --with-subcharts  charts/ervcp

# Tests

# TODO kubectl create ns .. && --set namespace=ervcp-dev-$(GIT_REV) for cicd
HELM_ARGS :=
KUBECONFIG := cicd_stage_1/kubeconfig-public.yaml
deploy-app:
	helm install --kubeconfig $(KUBECONFIG) --wait $(HELM_ARGS) ervcp-$(GIT_REV) charts/ervcp/ \
	--set image.tag=$(APP_VERSION) \
	--namespace ervcp-$(GIT_REV) \
	--create-namespace

cleanup-app:
	helm delete --kubeconfig $(KUBECONFIG) $(HELM_ARGS) ervcp-$(GIT_REV)  --namespace ervcp-$(GIT_REV)

.PHONY: fix
fix:
	golangci-lint run -v --fix ./...
