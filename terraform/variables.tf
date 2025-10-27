variable "cluster_name" {
  type    = string
  default = "my-eks-cluster"
}
variable "instance_types" {
  default = ["t3.medium"]
}
variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.28"  # Repo default; update to "1.29" for security if desired
}

variable "environment" {
  description = "Environment tag (e.g., dev, prod)"
  type        = string
  default     = "dev"
}


variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"  # Guide region
}

variable "db_username" {
  description = "RDS database username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "RDS database password"
  type        = string
  default     = "SecurePass123!"  # Change for security
}