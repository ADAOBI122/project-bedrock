module "eks" {

  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"


  name = "project-bedrock-cluster"

  kubernetes_version = "1.35"
  enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  endpoint_public_access = true


  vpc_id = module.vpc.vpc_id

  subnet_ids = module.vpc.private_subnets


  enable_cluster_creator_admin_permissions = true


  eks_managed_node_groups = {

    default = {

      instance_types = ["t3.small"]

      min_size = 2

      max_size = 3

      desired_size = 2

    }

  }


  tags = {

    Project = "tinyuka-2025-capstone"

  }

}

