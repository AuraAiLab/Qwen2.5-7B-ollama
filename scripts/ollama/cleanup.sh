#!/bin/bash
# Script to clean up Qwen2.5-7B Ollama deployment from Kubernetes

set -e

echo "WARNING: This will remove the Ollama deployment and its associated resources."
read -p "Are you sure you want to proceed? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cleanup cancelled."
    exit 0
fi

# Delete the Kubernetes resources
echo "Removing Ollama Kubernetes resources..."
kubectl delete -f ../../k8s/ollama/ollama-service.yaml --ignore-not-found
kubectl delete -f ../../k8s/ollama/ollama-deployment.yaml --ignore-not-found

# Ask if the user wants to delete the PVC (which deletes the data)
read -p "Do you also want to delete the PersistentVolumeClaim (this will delete all model data)? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Deleting Ollama PVC..."
    kubectl delete pvc -n ollama ollama-pvc --ignore-not-found
    echo "PVC deleted successfully."
else
    echo "PVC preserved. Data will be available when you redeploy."
fi

echo "Cleanup completed successfully."
