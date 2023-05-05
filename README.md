# Iris Data Pipeline K8s

## Prerequisites

- Install [Docker](https://docs.docker.com/engine/install/).
- Install [Minikube](https://minikube.sigs.k8s.io/docs/start/).
- Install [Helm](https://helm.sh/docs/intro/install/).

## Preparation

Install [Anaconda](https://docs.anaconda.com/anaconda/install/index.html) and execute the following commands:

```bash
$ make env      # create a conda environment (need only once)
$ conda activate iris-data-pipeline-k8s
$ make init     # setup packages (need only once)
```

## How To Play

### 1. K8s Cluster Setup

```bash
$ make cluster          # create a k8s cluster (need only once)
```

You can delete the k8s cluster.

```bash
$ make cluster-clean    # delete the k8s cluster
```

### 2. Source & Target DB Setup

```bash
$ make mongodb-operator     # create a mongodb operator
$
$ make mongodb              # create a mongodb
$
$ make postgres             # create a postgres
```

You can delete mongodb and postgres.

```bash
$ make mongodb-clean        # delete the mongodb
$
$ make postgres-clean       # delete the postgres
```

### 3. Kafka Cluster Setup

```bash
$ make kafka-operator       # create a kafka operator w/ strimzi
$
$ make kafka-cluster        # create a kafka cluster
```

You can delete kafka cluster.

```bash
$ make kafka-clean        # delete the kafka cluster
```

## For Developers

```bash
$ make check          # all static analysis scripts
$ make format         # format scripts
$ make lint           # lints scripts
```
