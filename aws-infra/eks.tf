# To create an EKS cluster

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

module "eks" {
  source           = "terraform-aws-modules/eks/aws"
  version          = "17.24.0"
  depends_on       = [module.vpc]
  cluster_name     = var.cluster_name
  cluster_version  = var.k8s_version
  vpc_id           = module.vpc.vpc_id
  subnets          = module.vpc.private_subnets
  write_kubeconfig = false
  worker_groups = [{
    name          = "eks-production-worker-group"
    instance_type = var.node_instance_type
    key_name      = var.nodes_key_pair_name
    //disk_size          = var.bot_disk_size
    asg_desired_capacity = var.desired_nodes
    asg_max_size         = var.max_nodes
    asg_min_size         = var.min_nodes
    suspended_processes  = ["AZRebalance"]

    tags = [
      {
        "key"                 = "k8s.io/cluster-autoscaler/enabled"
        "propagate_at_launch" = "true"
        "value"               = "true"
      },
      {
        "key"                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
        "propagate_at_launch" = "true"
        "value"               = "true"
      },
    ]
    },
  ]
  workers_additional_policies = ["arn:aws:iam::aws:policy/AutoScalingFullAccess"]
  map_users                   = var.map_users
}

locals {
  asg = module.eks.workers_asg_names[0]
}

resource "aws_autoscaling_policy" "bat" {
  depends_on             = [module.eks]
  name                   = "eks-node-autoscaling"
  policy_type            = "TargetTrackingScaling"
  adjustment_type        = "PercentChangeInCapacity"
  autoscaling_group_name = local.asg
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.node_avg_cpu_utilization
  }
}