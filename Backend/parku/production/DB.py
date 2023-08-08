import mysql.connector

DB_HOST = "localhost"
DB_USER = "backend"
DB_PASS = "BE@parku1"
DB_NAME = "parku_schema"

def connectDB():
    db = mysql.connector.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASS,
        database=DB_NAME
    )
    return db


def main():
    pass

if __name__ == "__main__":
    main()