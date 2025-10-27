terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"  # Pins to v5.x (fixes compatibility with EKS v20.x)
    }
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"  # Repo pin

  name = "scalable-cloud-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]  # Multi-AZ for uptime
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  database_subnets = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]  # Added for RDS
  create_database_subnet_group = true  # Enables db_subnet_group_name

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"  # Repo pin; uses eks_managed_node_groups

  cluster_name    = "scalable-cloud-eks"
  cluster_version = "1.30"  # Repo value; stable as of Oct 2025

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access        = true
  cluster_endpoint_public_access_cidrs  = ["0.0.0.0/0"]  # Allows all IPs for testing (restrict to your IP/32 in prod)

  # Add-ons for core functionality
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  enable_irsa = true  # For IAM roles in manifests

  # Managed node groups (fixed syntax for v20.x)
  eks_managed_node_groups = {
    general = {
      desired_size = 2  # Initial
      min_size     = 1  # Min availability
      max_size     = 4  # Max for HPA

      instance_types = ["t3.medium"]  # Array; repo bug fixed
      capacity_type  = "SPOT"  # Added for 25% savings (repo goal)

      k8s_labels = {
        Environment = "dev"
        Role        = "general"
      }
    }
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"  # Repo pin

  identifier = "scalable-cloud-rds"

  engine               = "postgres"
  engine_version       = "15.14"
  family               = "postgres15"
  major_engine_version = "15"

  instance_class        = "db.t3.medium"
  allocated_storage     = 20
  max_allocated_storage = 100

  db_name  = "scalablecloud"
  username = "postgres"
  password = "SecurePass123!"  # Added (repo missing; use Secrets Manager in prod)

  vpc_security_group_ids = [module.vpc.default_security_group_id]

  db_subnet_group_name = module.vpc.database_subnet_group_name  # Now works with added subnets

  publicly_accessible = false

  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  multi_az               = true  # For 99.9% uptime

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}