PYTHON=3.10
BASENAME=$(shell basename $(CURDIR))
PROFILE_NAME=iris-data-pipeline-k8s

env:
	conda create -y -n $(BASENAME) python=$(PYTHON)

all: init format lint

check: format lint

install-pdm:
	@echo "Install pdm";\
	if [ `command -v pip` ];\
		then pip install pdm;\
	else\
		curl -sSL https://raw.githubusercontent.com/pdm-project/pdm/main/install-pdm.py | python3 -;\
	fi;

init:
	@echo "Construct development environment";\
	if [ -z $(VIRTUAL_ENV) ]; then echo Warning, Virtual Environment is required; fi;\
	if [ -z `command -v pdm` ];\
		then make install-pdm;\
	fi;\
	pip install -U pip
	pdm install
	pdm run pre-commit install

format:
	pdm run black .

lint:
	pdm run pyright src
	pdm run ruff src --fix

cluster:
	minikube start --driver=docker --profile $(PROFILE_NAME) --extra-config=kubelet.housekeeping-interval=10s --cpus=max --memory=max
	minikube addons enable metrics-server --profile $(PROFILE_NAME)
	minikube addons list --profile $(PROFILE_NAME)

cluster-clean:
	minikube delete --profile $(PROFILE_NAME)
