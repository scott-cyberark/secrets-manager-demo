"""Sample DB-connecting app - AFTER.

Same app as hardcoded_app.py, but credentials are pulled dynamically from
Idira Secrets Manager at startup instead of being embedded in source.
"""
from idira_client import IdiraClient

DB_HOST = "app-db.internal.example.com"
DB_NAME = "appdb"

# "Safe/Secret" path convention, same as used in .github/workflows/secrets.yml
SECRET_PATH_USERNAME = "data/vault/SM-DB-SecretHub/app-db/username"
SECRET_PATH_PASSWORD = "data/vault/SM-DB-SecretHub/app-db/password"


def connect():
    client = IdiraClient()
    db_username = client.get_secret(SECRET_PATH_USERNAME)
    db_password = client.get_secret(SECRET_PATH_PASSWORD)

    print(f"Connecting to {DB_HOST}/{DB_NAME} as '{db_username}' ...")
    # conn = psycopg2.connect(
    #     host=DB_HOST, dbname=DB_NAME, user=db_username, password=db_password
    # )
    print("Connected (simulated) using credentials fetched from Idira Secrets Manager.")


if __name__ == "__main__":
    connect()
