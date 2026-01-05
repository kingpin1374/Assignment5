from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  #
@app.route('/process', methods=['POST'])
def process_data():
    
    data = request.get_json()
    
    name = data.get('name')
    email = data.get('email')
    
   
    if name and email:
        response_message = f"Success! Backend received: {name} ({email})"
    else:
        response_message = "Backend received incomplete data."

    return jsonify({
        "status": "received",
        "message": response_message
    })

if __name__ == '__main__':
   
    app.run(host='0.0.0.0', port=8000)
