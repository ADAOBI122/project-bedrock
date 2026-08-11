resource "aws_eks_access_entry" "developer" {

  cluster_name = var.cluster_name

  principal_arn = aws_iam_user.bedrock_dev_view.arn

  depends_on = [module.eks]

}



resource "aws_eks_access_policy_association" "developer_view" {


  cluster_name = var.cluster_name


  principal_arn = aws_iam_user.bedrock_dev_view.arn


  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"


  access_scope {

    type = "namespace"

    namespaces = [
      "retail-app"
    ]

  }

  depends_on = [module.eks]

}
