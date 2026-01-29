from flask import Flask, request, jsonify
from flask_cors import CORS
from pymongo import MongoClient
from pymongo.errors import ServerSelectionTimeoutError
import os
import time

app = Flask(__name__)
CORS(app)

# MongoDB connection with retry
mongo_url = os.getenv('MONGO_URL', 'mongodb://mongo:27017')
max_retries = 5
retry_count = 0
client = None
db = None
collection = None

while retry_count < max_retries:
    try:
        client = MongoClient(mongo_url, serverSelectionTimeoutMS=5000)
        # Test the connection
        client.admin.command('ping')
        db = client['assignment_db']
        collection = db['submissions']
        print(f"Connected to MongoDB at {mongo_url}")
        break
    except ServerSelectionTimeoutError:
        retry_count += 1
        print(f"Failed to connect to MongoDB (attempt {retry_count}/{max_retries}). Retrying...")
        time.sleep(2)

if client is None:
    print(f"Warning: Could not connect to MongoDB after {max_retries} attempts")
    db = None
    collection = None

@app.route('/process', methods=['POST'])
def process_data():
    
    data = request.get_json()
    
    name = data.get('name')
    email = data.get('email')
    
   
    if name and email:
        # Store in MongoDB if connected
        if collection is not None:
            try:
                collection.insert_one({'name': name, 'email': email})
            except Exception as e:
                print(f"Error saving to MongoDB: {e}")
        response_message = f"Success! Backend received: {name} ({email})"
    else:
        response_message = "Backend received incomplete data."

    return jsonify({
        "status": "received",
        "message": response_message
    })

if __name__ == '__main__':
   
    app.run(host='0.0.0.0', port=8000)
