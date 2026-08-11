resource "aws_eks_node_group" "main" {

  cluster_name = module.eks.cluster_name

  node_group_name = "project-bedrock-node-group"

  node_role_arn = aws_iam_role.eks_node_role.arn

  subnet_ids = module.vpc.private_subnets


  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }


  instance_types = [
    "t3.small"
  ]


  tags = {
    Project = "tinyuka-2025-capstone"
  }
}
