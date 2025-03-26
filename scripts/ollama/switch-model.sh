#!/bin/bash
# Script to switch between different AI models in Ollama

set -e

# Default model to switch to if none specified
DEFAULT_MODEL="qwen2.5:7b"

# Available models
MODELS=("mistral:7b" "qwen2.5:7b" "browser-qwen" "mistral-web:latest")

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
    curl -s http://192.168.20.22:11434/api/tags | grep -o '"name":"[^"]*"' | sed 's/"name":"//g' | sed 's/"//g'
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

# Ollama endpoint
OLLAMA_ENDPOINT="http://192.168.20.22:11434"

echo "Switching to model: $MODEL"

# Check if Ollama is accessible
if curl -s $OLLAMA_ENDPOINT/api/tags > /dev/null; then
    # Check if the model exists
    MODEL_EXISTS=$(curl -s $OLLAMA_ENDPOINT/api/tags | grep -c "$MODEL" || true)
    
    if [ "$MODEL_EXISTS" -eq 0 ]; then
        echo "Model $MODEL not found on the server."
        echo "Please check that the model is properly installed."
        exit 1
    else
        echo "Model $MODEL exists on the server."
    fi
    
    # Test the model with a simple prompt
    echo "Testing the model with a simple prompt..."
    curl -X POST $OLLAMA_ENDPOINT/api/generate -d "{
        \"model\": \"$MODEL\",
        \"prompt\": \"Hello, I am an AI assistant. Please respond with a short greeting.\",
        \"stream\": false
    }"
    
    echo ""
    echo "Successfully switched to $MODEL."
    echo "You can interact with it using the Ollama API at $OLLAMA_ENDPOINT/api/generate"
    
    # Display env var settings for easy copy-paste
    echo ""
    echo "To use with applications or APIs, set these environment variables:"
    echo "export OLLAMA_HOST=$OLLAMA_ENDPOINT"
    echo "export OLLAMA_MODEL=$MODEL"
else
    echo "Failed to connect to Ollama at $OLLAMA_ENDPOINT"
    echo "Please check that the Ollama server is running and accessible."
fi

echo "Operation complete."
