from flask import Flask, request, jsonify
import requests

app = Flask(__name__)

OLLAMA_SERVER = 'http://192.168.20.22:11434'

@app.route('/', methods=['POST'])
def proxy():
    try:
        # Forward request to Ollama server
        response = requests.post(OLLAMA_SERVER, json=request.json)
        data = response.json()

        # Fix response if it's a list
        if isinstance(data.get('response'), list):
            data['response'] = data['response'][0] if data['response'] else {}

        return jsonify(data)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
