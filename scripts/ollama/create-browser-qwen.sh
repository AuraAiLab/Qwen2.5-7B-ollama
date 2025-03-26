#!/bin/bash
# Script to create a custom browser-qwen model with proper JSON formatting

set -e

echo "Creating browser-qwen model to fix JSON formatting issues..."

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Get the Ollama pod name
OLLAMA_POD=$(kubectl get pods -n ollama -l app=ollama -o jsonpath='{.items[0].metadata.name}')

if [ -z "$OLLAMA_POD" ]; then
    echo "Error: Ollama pod not found. Please make sure Ollama is running."
    exit 1
fi

echo "Found Ollama pod: $OLLAMA_POD"

# Get the absolute path to the Modelfile
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"
MODELFILE_PATH="$REPO_ROOT/configs/ollama/browser-fix/Modelfile"

# Check if the Modelfile exists
if [ ! -f "$MODELFILE_PATH" ]; then
    echo "Error: Modelfile not found at $MODELFILE_PATH"
    exit 1
fi

# Copy the Modelfile to the pod
echo "Copying Modelfile to the Ollama pod..."
kubectl cp "$MODELFILE_PATH" ollama/$OLLAMA_POD:/tmp/browser-qwen-modelfile

# Create the model
echo "Creating browser-qwen model..."
kubectl exec -n ollama $OLLAMA_POD -- ollama create browser-qwen -f /tmp/browser-qwen-modelfile

# Verify model creation
echo "Verifying model creation..."
kubectl exec -n ollama $OLLAMA_POD -- ollama list

echo "Testing model with a simple JSON generation prompt..."
kubectl exec -n ollama $OLLAMA_POD -- ollama run browser-qwen "Generate a simple JSON with user information including name and age"

echo ""
echo "Setup complete. Your browser-qwen model is now ready for use with Browser-Use."
echo "Make sure to update your Browser-Use configuration as described in the documentation."
echo ""
echo "Ollama API endpoint: http://192.168.20.22:11434"
echo "Model name: browser-qwen"
