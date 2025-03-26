# Qwen2.5-7B-ollama

## Overview
This repository documents the installation and deployment of the Qwen2.5-7B model on Ollama in a Kubernetes-based infrastructure. It serves as a reference for the setup process and future deployments.

## Project Goals
1. Setup Qwen2.5-7B on Ollama using Kubernetes
2. Document the process, challenges, and solutions
3. Provide reusable configurations and scripts

## Directory Structure
```
Qwen2.5-7B-ollama/
├── docs/                      # Documentation
│   ├── setup-guides/          # Setup guides for the model
│   └── troubleshooting/       # Troubleshooting information
├── scripts/                   # Installation and helper scripts
│   └── ollama/                # Scripts for Ollama setup
├── configs/                   # Configuration files
│   └── ollama/                # Ollama configurations
├── k8s/                       # Kubernetes manifests
│   └── ollama/                # Ollama K8s configuration
├── issues/                    # Documented issues and resolutions
└── logs/                      # Installation logs
```

## Installation Requirements
Based on the Kubernetes cluster setup, the following components are expected to be available:
- Kubernetes cluster (v1.32.3)
- Containerd runtime
- Calico CNI (v3.26.1)
- MetalLB (v0.13.12)
- NVIDIA GPU Operator
- Namespace: ollama

## License
This project is licensed under the MIT License - see the LICENSE file for details.

## About
A project to document the installation and deployment of Qwen2.5-7B model on Ollama using a Kubernetes cluster.
