# Triton  Server Deployment And Model Analyzer

A production-ready deployment configuration for NVIDIA Triton Inference Server on Kubernetes, supporting both direct manifest deployment and Helm-based installation.

## Overview

This repository provides Kubernetes deployment configurations for NVIDIA Triton Inference Server, enabling high-performance inference serving for machine learning models. The deployment includes automatic model downloading, GPU resource allocation, and persistent storage management.

## Features

- **GPU-Accelerated Inference**: Configured for NVIDIA GPU utilization with resource limits and requests
- **Automatic Model Loading**: Init container automatically downloads and configures popular ONNX models
- **Persistent Storage**: EFS-based persistent volume for model repository storage
- **Multiple Deployment Options**: Support for both direct Kubernetes manifests and Helm charts
- **Production Ready**: Includes service definitions and proper resource management
- **Multi-Protocol Support**: HTTP, gRPC, and metrics endpoints exposed

## Pre-configured Models

The deployment automatically downloads and configures the following models:

- **Inception v3**: Image classification model converted from TensorFlow to ONNX format
- **DenseNet-121**: Pre-trained computer vision model for image classification

## Architecture

The deployment consists of:

- **Triton Server Container**: NVIDIA Triton Inference Server (v25.06-py3)
- **Model Download Init Container**: Downloads and prepares models before server startup
- **Persistent Volume**: EFS storage for model repository persistence
- **Service**: Exposes inference endpoints on multiple ports

## Prerequisites

- Kubernetes cluster with GPU node(s)
- NVIDIA GPU Operator or device plugin installed
- EFS CSI driver configured (for persistent storage)
- Storage class `efs-sc` available
- kubectl configured for cluster access

## Deployment Options

### Option 1: Direct Kubernetes Manifests

Deploy using the provided Kubernetes YAML files:

```bash
# Create persistent volume claim
kubectl apply -f triton_pvc.yaml

# Deploy Triton server
kubectl apply -f triton_deployment.yaml

# Create service
kubectl apply -f triton_service.yaml

# (Optional) Apply additional configurations
kubectl apply -f triton.yaml
```

### Option 2: Helm Chart Deployment

Deploy using the included Helm chart for more flexibility:

```bash
# Install the Helm chart
helm install triton-server ./Triton

# Or with custom values
helm install triton-server ./Triton -f custom-values.yaml
```

## Configuration

### Resource Requirements

- **GPU**: 1 NVIDIA GPU per pod (configurable)
- **Storage**: 100Gi persistent volume (EFS)
- **CPU/Memory**: Default Kubernetes limits apply

### Exposed Ports

- **8000**: HTTP inference endpoint
- **8001**: gRPC inference endpoint  
- **8002**: Metrics and health check endpoint

### Helm Chart Configuration

Key configuration options in `Triton/values.yaml`:

```yaml
tritonServerDeployment:
  replicas: 1
  tritonContainer:
    image:
      repository: nvcr.io/nvidia/tritonserver
      tag: 25.06-py3
    resources:
      limits:
        nvidia.com/gpu: "1"
      requests:
        nvidia.com/gpu: "1"

pvc:
  modelRepoClaim:
    storageClass: efs-sc
    storageRequest: 100Gi
```

## Usage

### Accessing the Server

Once deployed, you can access Triton server endpoints:

```bash
# Port forward to access locally
kubectl port-forward service/triton-http 8000:8000

# Check server health
curl http://localhost:8000/v2/health/ready

# List available models
curl http://localhost:8000/v2/models
```

### Model Inference

Submit inference requests to the deployed models:

```bash
# Example inference request (adjust payload as needed)
curl -X POST http://localhost:8000/v2/models/inception_onnx/infer \
  -H "Content-Type: application/json" \
  -d @inference_payload.json
```

## Monitoring

The deployment exposes metrics on port 8002:

```bash
# Access metrics endpoint
curl http://localhost:8002/metrics
```

## Customization

### Adding Custom Models

1. Modify `fetch_models.sh` to download your models
2. Ensure models follow Triton's repository structure
3. Update the script URL in deployment configurations

### Scaling

Adjust the number of replicas in the deployment:

```bash
# Using kubectl
kubectl scale deployment triton-server-deployment --replicas=3

# Using Helm
helm upgrade triton-server ./Triton --set tritonServerDeployment.replicas=3
```

## Troubleshooting

### Common Issues

1. **GPU Not Available**: Ensure NVIDIA GPU Operator is installed and nodes are properly labeled
2. **Storage Issues**: Verify EFS CSI driver is installed and `efs-sc` storage class exists
3. **Model Download Failures**: Check network connectivity and model URLs in `fetch_models.sh`

### Debugging Commands

```bash
# Check pod status
kubectl get pods -l app=triton

# View logs
kubectl logs -l app=triton -c triton-container

# Check init container logs
kubectl logs -l app=triton -c model-download

# Describe deployment
kubectl describe deployment triton-server-deployment
```

## Security Considerations

- The deployment downloads models from external URLs during initialization
- Consider using private registries for production environments
- Implement network policies as needed for your security requirements

## Contributing

When contributing to this repository:

1. Test changes in a development environment
2. Update documentation for any configuration changes
3. Ensure compatibility with the specified Triton server version

## License

This project is provided as-is for deployment of NVIDIA Triton Inference Server. Please refer to NVIDIA's licensing terms for Triton server usage.
