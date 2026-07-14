"""Sample DB-connecting app - BEFORE.

Credentials are hardcoded directly in source. This is what most apps look
like before adopting a secrets manager - compare with vault_app.py.
"""

DB_HOST = "app-db.internal.example.com"
DB_NAME = "appdb"
DB_USERNAME = "app_service"
DB_PASSWORD = "SuperSecretPassw0rd!"  # <-- hardcoded, checked into git, bad


def connect():
    print(f"Connecting to {DB_HOST}/{DB_NAME} as '{DB_USERNAME}' ...")
    # conn = psycopg2.connect(
    #     host=DB_HOST, dbname=DB_NAME, user=DB_USERNAME, password=DB_PASSWORD
    # )
    print("Connected (simulated).")


if __name__ == "__main__":
    connect()
