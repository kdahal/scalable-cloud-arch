module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.28"

  vpc_id     = aws_vpc.main.id  # Assume VPC creation or reference existing
  subnet_ids = aws_subnet.private[*].id

  eks_managed_node_groups = {
    default = {
      min_size     = 2
      max_size     = 5
      desired_size = 3

      instance_types = var.instance_types
      capacity_type  = "SPOT"  # For cost efficiency
    }
  }

  # Enable high availability
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  # Resource optimization
  node_groups_defaults = {
    disk_size = 20  # Right-sized
  }
}

# VPC (simplified; expand for production)
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "private" {
  count = 2  # Multi-AZ
  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
}

data "aws_availability_zones" "available" {}
