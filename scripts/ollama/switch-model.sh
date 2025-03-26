#!/bin/bash
# Script to switch between different AI models in Ollama

set -e

# Default model to switch to if none specified
DEFAULT_MODEL="qwen2.5:7b"

# Available models
MODELS=("mistral:7b" "qwen2.5:7b")

# Function to display usage
function show_usage {
    echo "Usage: $0 [model_name]"
    echo "Available models:"
    for model in "${MODELS[@]}"; do
        echo "  - $model"
    done
    echo ""
    echo "If no model is specified, defaults to $DEFAULT_MODEL"
}

# Function to list available models on the server
function list_models {
    echo "Checking available models on the Ollama server..."
    kubectl -n ollama port-forward svc/ollama-service 11434:11434 &
    PORT_FORWARD_PID=$!
    sleep 2
    
    MODELS_LIST=$(curl -s http://localhost:11434/api/tags)
    echo "Available models on server:"
    echo $MODELS_LIST | tr ',' '\n' | tr -d '{}"' | grep "name" | sed 's/name://g'
    
    kill $PORT_FORWARD_PID
}

# Parse command line arguments
MODEL="${1:-$DEFAULT_MODEL}"

if [ "$MODEL" == "--help" ] || [ "$MODEL" == "-h" ]; then
    show_usage
    exit 0
fi

if [ "$MODEL" == "--list" ] || [ "$MODEL" == "-l" ]; then
    list_models
    exit 0
fi

# Validate model selection
MODEL_VALID=false
for available_model in "${MODELS[@]}"; do
    if [ "$MODEL" == "$available_model" ]; then
        MODEL_VALID=true
        break
    fi
done

if [ "$MODEL_VALID" == "false" ]; then
    echo "Error: Invalid model '$MODEL'."
    show_usage
    exit 1
fi

# Get the Ollama pod name
OLLAMA_POD=$(kubectl get pods -n ollama -l app=ollama -o jsonpath='{.items[0].metadata.name}')

echo "Found Ollama pod: $OLLAMA_POD"
echo "Switching to model: $MODEL"

# Set up port-forwarding in the background
echo "Setting up port-forwarding to access Ollama..."
kubectl -n ollama port-forward svc/ollama-service 11434:11434 &
PORT_FORWARD_PID=$!

# Give port-forwarding a moment to establish
sleep 3

# Check if Ollama is accessible
if curl -s http://localhost:11434/api/tags > /dev/null; then
    # Check if the model exists, pull it if it doesn't
    MODEL_EXISTS=$(curl -s http://localhost:11434/api/tags | grep -c "$MODEL" || true)
    
    if [ "$MODEL_EXISTS" -eq 0 ]; then
        echo "Model $MODEL not found. Pulling the model..."
        curl -X POST http://localhost:11434/api/pull -d "{\"name\": \"$MODEL\"}"
    else
        echo "Model $MODEL already exists."
    fi
    
    # Test the model with a simple prompt
    echo "Testing the model with a simple prompt..."
    curl -X POST http://localhost:11434/api/generate -d "{
        \"model\": \"$MODEL\",
        \"prompt\": \"Hello, I am an AI assistant.\",
        \"stream\": false
    }"
    
    echo ""
    echo "Successfully switched to $MODEL."
    echo "You can interact with it using the Ollama API at http://localhost:11434/api/generate"
    
    # Get external service details if available
    EXTERNAL_IP=$(kubectl get svc -n ollama ollama-external -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
    if [ -n "$EXTERNAL_IP" ]; then
        echo "Ollama external service is accessible at: http://$EXTERNAL_IP:11434"
    fi
else
    echo "Failed to connect to Ollama. Check the pod logs for issues:"
    kubectl -n ollama logs -l app=ollama
fi

# Clean up port-forwarding
kill $PORT_FORWARD_PID

echo "Operation complete."
