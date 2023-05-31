FROM amd64/python:3.10-slim

WORKDIR /usr/app

RUN apt-get update && apt-get install -y \
  postgresql-client \
  kafkacat \
  && rm -rf /var/lib/apt/lists/*

RUN pip install -U pip \
  && pip install psycopg2-binary
