#!/bin/bash
set -e

# Apply Terraform
cd ../terraform
terraform apply -auto-approve

# Update kubeconfig
aws eks update-kubeconfig --name my-eks-cluster --region us-west-2

# Apply K8s
cd ../kubernetes
kubectl apply -f .

echo "Deployment complete. Check status with kubectl get all"
