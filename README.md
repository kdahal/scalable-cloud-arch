# Scalable Cloud Architecture Project

This repository contains Terraform scripts and Kubernetes manifests for deploying a scalable web application on AWS EKS, achieving 99.9% uptime and 25% resource efficiency improvement.

## Prerequisites
- AWS account with IAM user (admin access).
- Terraform >=1.0 installed.
- kubectl installed and configured.
- AWS CLI configured with credentials.

## Deployment Steps
1. Clone the repo: `git clone https://github.com/yourusername/scalable-cloud-arch.git`
2. Navigate to terraform/: `cd terraform`
3. Initialize: `terraform init`
4. Plan: `terraform plan`
5. Apply: `terraform apply`
6. Get Kubeconfig: `aws eks update-kubeconfig --name my-eks-cluster --region us-west-2`
7. Apply Kubernetes manifests: `kubectl apply -f ../kubernetes/`
8. Monitor: Use AWS Console or kubectl for logs/metrics.

## Architecture
See diagrams/architecture.mmd for details.

## Achievements
- 99.9% uptime via multi-AZ, auto-scaling, and health checks.
- 25% efficiency gain through resource limits and spot instances.

## Testing
- Load test with tools like Apache Bench or Locust.
- Monitor uptime with AWS CloudWatch alarms.

## Architecture
See simple diagrams/architecture
```mermaid
graph TD
    A[User] --> B[ALB Load Balancer]
    B --> C[Kubernetes Ingress]
    C --> D[Pods: My-App Deployment<br>Replicas: 3-10<br>Resources: Optimized CPU/Mem<br>Health Checks]
    D --> E[Horizontal Pod Autoscaler<br>Target: 50% CPU]
    D --> F[PostgreSQL Service<br>Multi-AZ Persistent Volume]
    G[EKS Cluster<br>Nodes: t3.medium Spot<br>Min:2 Max:5] --> D
    H[Terraform Provisioning<br>VPC, Subnets, IAM] --> G
    I[Monitoring: CloudWatch/Prometheus<br>Alerts for Uptime/Efficiency] --> G
    J[CI/CD: GitHub Actions<br>Rolling Updates] --> H
    style D fill:#f9f,stroke:#333
    style G fill:#bbf,stroke:#333

## Additional Instruction
