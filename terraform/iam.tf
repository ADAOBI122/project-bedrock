# ==========================================
# EKS WORKER NODE ROLE
# ==========================================

resource "aws_iam_role" "eks_node_role" {
  name = "project-bedrock-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project = "tinyuka-2025-capstone"
  }
}


resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}


resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}


resource "aws_iam_role_policy_attachment" "eks_container_registry_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}


# ==========================================
# AWS LOAD BALANCER CONTROLLER POLICY
# ==========================================

resource "aws_iam_policy" "aws_load_balancer_controller" {

  name = "AWSLoadBalancerControllerIAMPolicy"

  policy = file("${path.module}/aws-load-balancer-controller-policy.json")

  tags = {
    Project = "tinyuka-2025-capstone"
  }
}


# ==========================================
# DEVELOPER IAM USER
# ==========================================

resource "aws_iam_user" "bedrock_dev_view" {

  name = "bedrock-dev-view"

  tags = {
    Project = "tinyuka-2025-capstone"
  }
}


# Console read-only access
resource "aws_iam_user_policy_attachment" "bedrock_readonly" {

  user = aws_iam_user.bedrock_dev_view.name

  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}


# ==========================================
# DEVELOPER S3 ACCESS
# ==========================================

resource "aws_iam_user_policy" "bedrock_s3_upload" {

  name = "bedrock-s3-upload"

  user = aws_iam_user.bedrock_dev_view.name


  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {
        Effect = "Allow"

        Action = [
          "s3:PutObject"
        ]

        Resource = "arn:aws:s3:::bedrock-assets-alt-soe-tin-025-0061/*"
      }

    ]

  })
}


# ==========================================
# LAMBDA EXECUTION ROLE
# ==========================================

resource "aws_iam_role" "lambda_execution_role" {

  name = "bedrock-asset-processor-role"


  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Effect = "Allow"

        Principal = {

          Service = "lambda.amazonaws.com"

        }

        Action = "sts:AssumeRole"

      }

    ]

  })


  tags = {

    Project = "tinyuka-2025-capstone"

  }

}



resource "aws_iam_role_policy_attachment" "lambda_logs" {

  role = aws_iam_role.lambda_execution_role.name


  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"

}


# Lambda only reads objects from the assets bucket

resource "aws_iam_role_policy" "lambda_s3_read" {


  name = "lambda-s3-read"


  role = aws_iam_role.lambda_execution_role.id


  policy = jsonencode({

    Version = "2012-10-17"


    Statement = [

      {

        Effect = "Allow"


        Action = [

          "s3:GetObject"

        ]


        Resource = "arn:aws:s3:::bedrock-assets-alt-soe-tin-025-0061/*"

      }

    ]

  })
}
