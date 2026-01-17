from flask import Flask, request
import psycopg2
import os

app = Flask(__name__)

# K8s will inject these variables
DB_HOST = os.getenv("DB_HOST", "db-service")
DB_NAME = os.getenv("POSTGRES_DB", "names_db")
DB_USER = os.getenv("POSTGRES_USER", "postgres")
DB_PASS = os.getenv("POSTGRES_PASSWORD", "password123")

def get_db_connection():
    return psycopg2.connect(host=DB_HOST, database=DB_NAME, user=DB_USER, password=DB_PASS)

@app.route("/", methods=["GET", "POST"])
def index():
    if request.method == "POST":
        name = request.form["name"]
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("CREATE TABLE IF NOT EXISTS users (name TEXT);")
        cur.execute("INSERT INTO users (name) VALUES (%s)", (name,))
        conn.commit()
        cur.close()
        conn.close()

    return '<h1>Name Collector</h1><form method="POST"><input name="name"><input type="submit"></form>'

if __name__ == "__main__":
    # Changed from 8080 to 5555
    app.run(host="0.0.0.0", port=5555)