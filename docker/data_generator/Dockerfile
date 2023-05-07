FROM amd64/python:3.9-slim

WORKDIR /usr/app

RUN pip install -U pip &&\
    pip install pymongo==4.3.3 pandas==2.0.1 scikit-learn==1.2.2

COPY docker/data_generator/data_generator.py data_generator.py
