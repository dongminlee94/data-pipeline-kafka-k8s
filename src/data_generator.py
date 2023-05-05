"""Data generator."""
import time
from argparse import ArgumentParser

import pandas as pd
from pymongo import MongoClient
from pymongo.collection import Collection
from sklearn.datasets import load_iris


def create_collection(client: MongoClient) -> Collection:
    """Create collection."""
    database = client["mongodatabase"]
    if "iris_data" not in database.list_collection_names():
        database.create_collection("iris_data")
    return database["iris_data"]


def get_data() -> pd.DataFrame:
    """Get data."""
    inputs, labels = load_iris(return_X_y=True, as_frame=True)
    df = pd.concat([inputs, labels], axis="columns")
    rename_rule = {
        "sepal length (cm)": "sepal_length",
        "sepal width (cm)": "sepal_width",
        "petal length (cm)": "petal_length",
        "petal width (cm)": "petal_width",
    }
    df = df.rename(columns=rename_rule)
    return df


def insert_data(collection: Collection, data: pd.Series, count: int) -> None:
    """Insert data."""
    doc = data.to_dict()
    print(count, doc)
    collection.insert_one(doc)


def generate_data(collection: Collection, df: pd.DataFrame) -> None:
    """Generate data."""
    count = 0
    while True:
        insert_data(collection=collection, data=df.sample(1).squeeze(), count=count)
        count += 1
        time.sleep(5)


if __name__ == "__main__":
    parser = ArgumentParser()
    parser.add_argument("--db-host", dest="db_host", type=str, default="localhost")
    args = parser.parse_args()

    client = MongoClient(
        username="mongouser",
        password="mongopassword",
        host=args.db_host,
        port=27017,
        authSource="admin",
        connectTimeoutMS=60000,
        readPreference="primary",
        directConnection=True,
        ssl=False,
    )
    collection = create_collection(client=client)
    df = get_data()
    generate_data(collection=collection, df=df)
