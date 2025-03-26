#!/bin/bash
# Script to add Qwen2.5-7B model to existing Ollama installation
# This script assumes the Ollama pod is already running

set -e

echo "Adding Qwen2.5-7B model to existing Ollama installation..."

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Check if the ollama namespace exists
if ! kubectl get namespace ollama &> /dev/null; then
    echo "Namespace 'ollama' does not exist. Please ensure Ollama is properly set up."
    exit 1
fi

# Check if Ollama pod is running
if ! kubectl get pods -n ollama -l app=ollama &> /dev/null; then
    echo "No Ollama pods found. Please ensure Ollama is properly deployed."
    exit 1
fi

# Get the Ollama pod name
OLLAMA_POD=$(kubectl get pods -n ollama -l app=ollama -o jsonpath='{.items[0].metadata.name}')

echo "Found Ollama pod: $OLLAMA_POD"

# Set up port-forwarding in the background
echo "Setting up port-forwarding to access Ollama..."
kubectl -n ollama port-forward svc/ollama-service 11434:11434 &
PORT_FORWARD_PID=$!

# Give port-forwarding a moment to establish
sleep 5

# Check if Ollama is accessible
if curl -s http://localhost:11434/api/tags > /dev/null; then
    echo "Ollama is accessible. Pulling Qwen2.5-7B model..."
    
    # Pull Qwen2.5-7B model
    curl -X POST http://localhost:11434/api/pull -d '{"name": "qwen2.5:7b"}'
    
    echo "Qwen2.5-7B model pulled successfully."
    echo "Testing the model with a simple prompt..."
    
    # Test the model with a simple prompt
    curl -X POST http://localhost:11434/api/generate -d '{
        "model": "qwen2.5:7b",
        "prompt": "Hello, I am an AI assistant.",
        "stream": false
    }'
    
    echo ""
    echo "Qwen2.5-7B is set up and ready to use."
    echo "You can interact with it using the Ollama API at http://localhost:11434/api/generate"
else
    echo "Failed to connect to Ollama. Check the pod logs for issues:"
    kubectl -n ollama logs -l app=ollama
fi

# Clean up port-forwarding
kill $PORT_FORWARD_PID

echo "Setup complete."
