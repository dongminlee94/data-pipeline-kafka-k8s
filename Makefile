######################
#   initialization   #
######################
install-poetry:
	@echo "Install poetry";\
	curl -sSL https://install.python-poetry.org | python3 - --version 1.4.2

init:
	@echo "Construct development environment";\
	if [ -z $(VIRTUAL_ENV) ]; then echo Warning, Virtual Environment is required; fi;\
	if [ -z `command -v poetry` ];\
		then make install-poetry;\
	fi;\
	pip install -U pip
	poetry install
	poetry run pre-commit install

#######################
#   static analysis   #
#######################
check: format lint

format:
	poetry run black .

lint:
	poetry run pyright
	poetry run ruff docker --fix

###############
#   cluster   #
###############
PROFILE_NAME=iris-data-pipeline-k8s

cluster:
	minikube start --driver=docker --profile $(PROFILE_NAME) --extra-config=kubelet.housekeeping-interval=10s --cpus=max --memory=max
	minikube addons enable metrics-server --profile $(PROFILE_NAME)
	minikube addons list --profile $(PROFILE_NAME)

cluster-clean:
	minikube delete --profile $(PROFILE_NAME)

##############
#   tunnel   #
##############
tunnel:  # for loadbalancer access
	mkdir ~/.nohup && nohup minikube tunnel -p $(PROFILE_NAME) > ~/.nohup/minikube-tunnel-$(date +%Y-%m-%d-%Hh-%Ss) 2>&1 &

tunnel-clean:
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

############################
#   data generator image   #
############################
data-generator-image:
	docker build --platform linux/amd64 -f docker/data-generator/Dockerfile -t ghcr.io/dongminlee94/data-generator:latest .
	docker push ghcr.io/dongminlee94/data-generator:latest

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

#############
#   redis   #
#############
redis:
	helm upgrade redis helm/redis \
		-n redis --create-namespace --install

redis-clean:
	helm uninstall redis -n redis

######################
#   kafka operator   #
######################
kafka-operator:
	helm repo add strimzi https://strimzi.io/charts/
	helm upgrade kafka-operator strimzi/strimzi-kafka-operator \
		-n kafka-operator --create-namespace --install \
		--set watchAnyNamespace=true \

kafka-operator-clean:
	helm uninstall kafka-operator -n kafka-operator

#####################
#   kafka cluster   #
#####################
kafka-cluster:
	helm upgrade kafka-cluster helm/kafka-cluster \
		-n kafka --create-namespace --install

kafka-cluster-clean:
	helm uninstall kafka-cluster -n kafka
	kubectl delete -n kafka pvc --all

#######################
#   schema registry   #
#######################
schema-registry:
	minikube ssh --profile $(PROFILE_NAME) docker pull confluentinc/cp-schema-registry:7.3.0
	helm upgrade schema-registry helm/schema-registry \
		-n kafka --create-namespace --install

schema-registry-clean:
	helm uninstall schema-registry -n kafka

###########################
#   kafka connect image   #
###########################
kafka-connect-image:
	docker build --platform linux/amd64 -f docker/kafka-connect/Dockerfile -t ghcr.io/dongminlee94/kafka-connect:latest .
	docker push ghcr.io/dongminlee94/kafka-connect:latest

#####################
#   kafka connect   #
#####################
kafka-connect:
	helm upgrade kafka-connect helm/kafka-connect \
		-n kafka --create-namespace --install

kafka-connect-clean:
	helm uninstall kafka-connect -n kafka
