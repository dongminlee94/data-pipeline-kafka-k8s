"""Data generator."""
from time import sleep

import pandas as pd
from pymongo import MongoClient
from sklearn.datasets import load_iris


def load_data() -> pd.DataFrame:
    """Load data."""
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


def main(mongo_client: MongoClient) -> None:
    """Run main function."""
    # Create a collection
    collection = mongo_client["mongo"]["iris_data"]

    # Load iris data
    df = load_data()

    # Generate data continuously
    cnt = 0
    while True:
        doc = df.sample(1).squeeze().to_dict()
        result = collection.insert_one(doc)
        print(
            f"\nCount: {cnt}\n" f"ObjectID: {str(result.inserted_id)}\n" f"Doc: {doc}\n",
        )

        cnt += 1
        sleep(5)


if __name__ == "__main__":
    mongo_client = MongoClient(
        username="mongo",
        password="mongo",
        host="mongodb.mongodb.svc.cluster.local",
        port=27017,
        authSource="admin",
        connectTimeoutMS=60000,
        readPreference="primary",
        directConnection=True,
        ssl=False,
    )
    main(mongo_client=mongo_client)
