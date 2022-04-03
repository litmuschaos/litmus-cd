terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.74.1"
    }
  }
}
provider "aws" {
  region  = var.aws_region
  profile = "default"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

terraform {
  backend "s3" {
    bucket = "litmuschaos-production-terraform-state"
    key    = "state/terraform.tfstate"
    region = "us-east-1"
  }
}