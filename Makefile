PYTHON=3.10
BASENAME=$(shell basename $(CURDIR))
PROFILE_NAME=iris-data-pipeline-k8s
DOCKER_IMG_NAME := data-generator

######################
#   initialization   #
######################
env:
	conda create -y -n $(BASENAME) python=$(PYTHON)

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

#######################
#   static analysis   #
#######################
check: format lint

format:
	pdm run black .

lint:
	pdm run pyright
	pdm run ruff src --fix

##############
#   docker   #
##############
docker-image:
	docker build --platform linux/amd64 -f Dockerfile.$(DOCKER_IMG_NAME) -t ghcr.io/dongminlee94/$(DOCKER_IMG_NAME):latest . &&\
	docker push ghcr.io/dongminlee94/$(DOCKER_IMG_NAME):latest

###############
#   cluster   #
###############
cluster:
	minikube start --driver=docker --profile $(PROFILE_NAME) --extra-config=kubelet.housekeeping-interval=10s --cpus=max --memory=max
	minikube addons enable metrics-server --profile $(PROFILE_NAME)
	minikube addons list --profile $(PROFILE_NAME)

cluster-clean:
	minikube delete --profile $(PROFILE_NAME)

###############
#   access   #
###############
access:
	mkdir ~/.nohup && nohup minikube tunnel -p $(PROFILE_NAME) > ~/.nohup/minikube-tunnel-$(date +%Y-%m-%d-%Hh-%Ss) 2>&1 &

access-clean:
	rm -r ~/.nohup

#######################
#   mongodb-operator  #
#######################
mongodb-operator:
	helm repo add mongodb https://mongodb.github.io/helm-charts
	helm upgrade community-operator mongodb/community-operator \
		-n mongodb-operator --create-namespace --install \
		--set operator.watchNamespace="*"

mongodb-operator-clean:
	helm uninstall community-operator -n mongodb-operator

###############
#   mongodb   #
###############
mongodb:
	kubectl create namespace mongodb
	helm template -n mongodb --show-only templates/database_roles.yaml mongodb/community-operator | kubectl apply -f -
	helm upgrade mongodb helm/mongodb \
		-n mongodb --create-namespace --install

mongodb-clean:
	helm uninstall mongodb -n mongodb
	kubectl delete namespace mongodb

######################
#   data generator   #
######################
data-generator:
	helm upgrade data-generator helm/data-generator \
		-n data-generator --create-namespace --install

data-generator-clean:
	helm uninstall data-generator -n data-generator

################
#   postgres   #
################
postgres:
	helm upgrade postgres helm/postgres \
		-n postgres --create-namespace --install

postgres-clean:
	helm uninstall postgres -n postgres

###########################
#   postgres connection   #
###########################
postgres-connection:
	PGPASSWORD=postgrespassword psql -h localhost -p 5432 -U postgresuser -d postgresdatabase
