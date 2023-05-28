# Data Pipeline Kafka K8s

## Prerequisites

- Install [Docker](https://docs.docker.com/engine/install/).
- Install [Minikube](https://minikube.sigs.k8s.io/docs/start/).
- Install [Helm](https://helm.sh/docs/intro/install/).

## Preparation

Install Python 3.8 on [Pyenv](https://github.com/pyenv/pyenv#installation) or [Anaconda](https://docs.anaconda.com/anaconda/install/index.html) and execute the following commands:

```bash
$ make init     # setup packages (need only once)
```

## Infra Setup

### 1. K8s Cluster

```bash
$ make cluster          # create a k8s cluster (need only once)
```

You can delete the k8s cluster.

```bash
$ make cluster-clean    # delete the k8s cluster
```

### 2. Source DB, Target DB, and Message Queue

```bash
$ make mongodb-operator     # create a mongodb operator
$
$ make mongodb              # create a mongodb (source DB)
$
$ make postgres             # create a postgres (target DB)
$
$ make redis                # create a redis (message queue)
```

You can delete mongodb, postgres, and redis.

```bash
$ make mongodb-clean        # delete the mongodb
$
$ make postgres-clean       # delete the postgres
$
$ make redis-clean          # delete the redis
```

### 3. Kafka Cluster

```bash
$ make kafka-operator       # create a kafka operator w/ strimzi
$
$ make kafka-cluster        # create a kafka cluster
```

You can delete kafka cluster.

```bash
$ make kafka-clean        # delete the kafka cluster
```

### 4. Schema Registry & Kafka Connect

```bash
$ make schema-registry     # create a schema registry
$
$ make kafka-connect       # create a kafka connect
```

You can delete kafka connect and schema registry.

```bash
$ make schema-registry-clean    # delete the schema registry
$
$ make kafka-connect-clean      # delete the kafka connect
```

## For Developers

```bash
$ make check          # all static analysis scripts
$ make format         # format scripts
$ make lint           # lints scripts
```
