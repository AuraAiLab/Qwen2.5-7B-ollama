#!/bin/bash
# Script to install Qwen2.5-7B on Ollama in a Kubernetes environment

set -e

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "kubectl is not installed. Please install it first."
    exit 1
fi

# Create the ollama namespace if it doesn't exist
kubectl get namespace ollama &> /dev/null || kubectl create namespace ollama

# Apply Kubernetes manifests
echo "Deploying Ollama to Kubernetes..."
kubectl apply -f ../../k8s/ollama/ollama-deployment.yaml
kubectl apply -f ../../k8s/ollama/ollama-service.yaml

# Wait for the pod to be ready
echo "Waiting for Ollama pod to be ready..."
kubectl wait --for=condition=ready pods -l app=ollama -n ollama --timeout=300s

# Get the Ollama pod name
OLLAMA_POD=$(kubectl get pods -n ollama -l app=ollama -o jsonpath='{.items[0].metadata.name}')

# Pull the Qwen2.5-7B model
echo "Pulling Qwen2.5-7B model. This may take some time..."
kubectl exec -it $OLLAMA_POD -n ollama -- ollama pull qwen2.5:7b

# List available models to verify
echo "Verifying installation..."
kubectl exec -it $OLLAMA_POD -n ollama -- ollama list

echo "Qwen2.5-7B model has been successfully installed on Ollama!"
echo "You can access it by executing: kubectl exec -it $OLLAMA_POD -n ollama -- ollama run qwen2.5:7b"

# Get service details
OLLAMA_SERVICE_IP=$(kubectl get svc -n ollama ollama -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
if [ -z "$OLLAMA_SERVICE_IP" ]; then
    echo "Ollama service IP not available yet. Check with: kubectl get svc -n ollama"
else
    echo "Ollama service is accessible at: http://$OLLAMA_SERVICE_IP:11434"
fi
