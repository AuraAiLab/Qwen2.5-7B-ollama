# Qwen2.5-7B Setup Guide for Ollama

## Introduction
This guide details the process of setting up Qwen2.5-7B on Ollama within a Kubernetes environment. Qwen2.5-7B is a powerful language model developed by Alibaba's Qwen team, and this guide provides step-by-step instructions to deploy it using Ollama.

## Prerequisites
- Kubernetes cluster (v1.32.3+)
- Containerd runtime
- NVIDIA GPU with appropriate drivers and NVIDIA GPU Operator
- `kubectl` configured to access your cluster
- Namespace `ollama` created in your Kubernetes cluster

## Installation Steps

### 1. Create the Ollama Namespace (if not already created)
```bash
kubectl create namespace ollama
```

### 2. Deploy Ollama using Kubernetes
Apply the Kubernetes manifests from the `k8s/ollama` directory:
```bash
kubectl apply -f k8s/ollama/ollama-deployment.yaml
kubectl apply -f k8s/ollama/ollama-service.yaml
```

### 3. Pull the Qwen2.5-7B Model
Once Ollama is running, connect to the Ollama pod and pull the Qwen2.5-7B model:
```bash
# Get the Ollama pod name
OLLAMA_POD=$(kubectl get pods -n ollama -l app=ollama -o jsonpath='{.items[0].metadata.name}')

# Execute the pull command
kubectl exec -it $OLLAMA_POD -n ollama -- ollama pull qwen2.5:7b
```

### 4. Verify Installation
Verify that the model has been successfully pulled and is ready to use:
```bash
kubectl exec -it $OLLAMA_POD -n ollama -- ollama list
```

## Using the Model
You can use the model by running commands within the Ollama pod or by accessing it through the Ollama API service.

### Running Directly on the Pod
```bash
kubectl exec -it $OLLAMA_POD -n ollama -- ollama run qwen2.5:7b
```

### Using the Ollama API
If you've configured the Ollama service with external access, you can use the API endpoint:
```bash
curl -X POST http://<ollama-service-ip>:<ollama-service-port>/api/generate -d '{
  "model": "qwen2.5:7b",
  "prompt": "Tell me about quantum computing",
  "stream": false
}'
```

## Troubleshooting
If you encounter issues during the installation or usage of the model, refer to the troubleshooting documentation in `docs/troubleshooting/` or log your issue in the `issues/` directory.

## Additional Resources
- [Official Qwen GitHub Repository](https://github.com/QwenLM/Qwen)
- [Ollama Documentation](https://ollama.ai/docs)
