#########################################
# MySQL Security Group
#########################################

resource "aws_security_group" "mysql" {
  name        = "project-bedrock-mysql-sg"
  description = "Allow MySQL access only from EKS nodes"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name    = "project-bedrock-mysql-sg"
    Project = "tinyuka-2025-capstone"
  }
}

resource "aws_security_group_rule" "mysql_ingress" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.mysql.id
  source_security_group_id = module.eks.node_security_group_id
}

resource "aws_security_group_rule" "mysql_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.mysql.id
  cidr_blocks       = ["0.0.0.0/0"]
}

#########################################
# PostgreSQL Security Group
#########################################

resource "aws_security_group" "postgres" {
  name        = "project-bedrock-postgres-sg"
  description = "Allow PostgreSQL access only from EKS nodes"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name    = "project-bedrock-postgres-sg"
    Project = "tinyuka-2025-capstone"
  }
}

resource "aws_security_group_rule" "postgres_ingress" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.postgres.id
  source_security_group_id = module.eks.node_security_group_id
}

resource "aws_security_group_rule" "postgres_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.postgres.id
  cidr_blocks       = ["0.0.0.0/0"]
}
