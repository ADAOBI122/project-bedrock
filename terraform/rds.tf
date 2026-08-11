resource "aws_db_subnet_group" "bedrock" {

  name = "project-bedrock-db-subnet-group"

  subnet_ids = module.vpc.private_subnets

  tags = {
    Project = "tinyuka-2025-capstone"
  }

}



resource "aws_db_instance" "catalog_mysql" {

  identifier = "project-bedrock-catalog"

  engine = "mysql"

  engine_version = "8.0"

  instance_class = "db.t3.micro"

  allocated_storage = 20


  db_name = "catalog"

  username = "catalogadmin"

  password = "TempPassword123!"

  db_subnet_group_name = aws_db_subnet_group.bedrock.name


  vpc_security_group_ids = [
    aws_security_group.mysql.id
  ]


  publicly_accessible = false


  backup_retention_period = 1


  skip_final_snapshot = true


  tags = {
    Project = "tinyuka-2025-capstone"
  }

}



resource "aws_db_instance" "orders_postgres" {

  identifier = "project-bedrock-orders"

  engine = "postgres"

  engine_version = "16"

  instance_class = "db.t3.micro"

  allocated_storage = 20


  db_name = "orders"

  username = "ordersadmin"

  password = "TempPassword123!"


  db_subnet_group_name = aws_db_subnet_group.bedrock.name


  vpc_security_group_ids = [
    aws_security_group.postgres.id
  ]


  publicly_accessible = false


  backup_retention_period = 1


  skip_final_snapshot = true


  tags = {
    Project = "tinyuka-2025-capstone"
  }

}
