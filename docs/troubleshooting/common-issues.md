# Troubleshooting Guide for Qwen2.5-7B on Ollama

This document covers common issues that may arise when deploying and using the Qwen2.5-7B model on Ollama within a Kubernetes environment.

## Common Issues and Solutions

### GPU Resources Not Available

**Issue**: The pod is stuck in `Pending` state with a message about GPU resources not being available.

**Solution**: 
1. Verify that the NVIDIA GPU Operator is properly installed:
   ```bash
   kubectl get pods -n gpu-operator-resources
   ```
   
2. Check if the node has recognizable GPUs:
   ```bash
   kubectl describe nodes | grep -i nvidia
   ```
   
3. Ensure your pod resource requests match available GPU resources:
   ```bash
   # Modify the deployment to request the appropriate GPU resources
   kubectl edit deployment -n ollama ollama
   ```

### Model Download Failures

**Issue**: The model download fails with timeout or connection errors.

**Solution**:
1. Check internet connectivity from the pod:
   ```bash
   kubectl exec -it $(kubectl get pods -n ollama -l app=ollama -o jsonpath='{.items[0].metadata.name}') -n ollama -- ping github.com
   ```
   
2. Try setting a custom registry in your Modelfile:
   ```
   FROM qwen2.5:7b
   ```
   
3. If the network is restricted, consider downloading the model manually and importing it:
   ```bash
   # On a machine with good connectivity:
   ollama pull qwen2.5:7b
   ollama save qwen2.5:7b > qwen2.5-7b.tar
   
   # Copy to cluster and import:
   kubectl cp qwen2.5-7b.tar ollama/$(kubectl get pods -n ollama -l app=ollama -o jsonpath='{.items[0].metadata.name}'):/tmp/
   kubectl exec -it $(kubectl get pods -n ollama -l app=ollama -o jsonpath='{.items[0].metadata.name}') -n ollama -- ollama import /tmp/qwen2.5-7b.tar
   ```

### Insufficient Memory or Storage

**Issue**: The pod crashes with OOM (Out of Memory) errors or insufficient storage.

**Solution**:
1. Increase the memory limit in the deployment:
   ```yaml
   resources:
     limits:
       memory: "32Gi"  # Increase as needed
   ```
   
2. Increase the PVC size:
   ```bash
   # You'll need to delete and recreate the PVC with larger size
   # Make sure to back up your data first
   kubectl delete pvc -n ollama ollama-pvc
   # Edit the PVC spec to increase storage and reapply
   ```

### Pod Keeps Restarting

**Issue**: The Ollama pod keeps restarting or crashing.

**Solution**:
1. Check pod logs for specific errors:
   ```bash
   kubectl logs -n ollama $(kubectl get pods -n ollama -l app=ollama -o jsonpath='{.items[0].metadata.name}')
   ```
   
2. Check Kubernetes events:
   ```bash
   kubectl get events -n ollama
   ```
   
3. Ensure the docker.io/ollama/ollama:latest image is accessible to your cluster.

### Service Not Accessible

**Issue**: The Ollama service IP is not accessible.

**Solution**:
1. Verify that MetalLB or another LoadBalancer implementation is properly configured:
   ```bash
   kubectl get svc -n metallb-system
   ```
   
2. Check the Ollama service status:
   ```bash
   kubectl describe svc -n ollama ollama
   ```
   
3. Consider using NodePort or Ingress as alternatives if LoadBalancer is not an option.

## Performance Tuning

If the model is running too slowly:

1. Consider adjusting the container resources for better performance:
   ```yaml
   resources:
     limits:
       nvidia.com/gpu: 1
       cpu: "8"
       memory: "32Gi"
     requests:
       nvidia.com/gpu: 1
       cpu: "4"
       memory: "16Gi"
   ```

2. Tune the model parameters in the Modelfile for better inference speed.

## Reporting New Issues

If you encounter issues not covered in this guide, please document them in the `issues/` directory with detailed information about:
- The exact error message
- The steps to reproduce
- Your environment details
- Any solutions or workarounds discovered
