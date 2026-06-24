import os
from flask import Flask, jsonify
import mysql.connector

app = Flask(__name__)

db = mysql.connector.connect(
    host=os.getenv("DB_HOST"),
    user=os.getenv("DB_USER"),
    password=os.getenv("DB_PASS"),
    database=os.getenv("DB_NAME")
)

@app.route("/")
def home():
    return "Cloud App Connected to Database!"

@app.route("/users")
def users():
    cursor = db.cursor(dictionary=True)
    cursor.execute("SELECT * FROM users")
    return jsonify(cursor.fetchall())

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
