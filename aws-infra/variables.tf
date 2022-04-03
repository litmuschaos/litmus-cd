variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_name" {
  default = "litmuschaos-production-vpc"
}

variable "vpc_cidr" {
  default = "172.31.0.0/16"
}

variable "private_subnets_cidr" {
  type    = list(any)
  default = ["172.31.1.0/24", "172.31.2.0/24", "172.31.3.0/24"]
}

variable "public_subnets_cidr" {
  type    = list(any)
  default = ["172.31.101.0/24", "172.31.102.0/24", "172.31.103.0/24"]
}

variable "azs" {
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "cluster_name" {
  default = "litmuschaos-production-k8s-cluster"
}

variable "k8s_version" {
  default = "1.21"
}

variable "node_instance_type" {
  default = "t3.large"
}

variable "desired_nodes" {
  type    = number
  default = 3
}

variable "max_nodes" {
  type    = number
  default = 5
}

variable "min_nodes" {
  type    = number
  default = 3
}

variable "nodes_key_pair_name" {
  default = "litmuschaos-production-eks-nodes-key"
}

variable "node_avg_cpu_utilization" {
  type    = number
  default = 60
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
}