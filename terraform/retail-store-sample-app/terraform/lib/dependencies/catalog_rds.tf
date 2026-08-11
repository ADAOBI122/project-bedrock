resource "aws_db_instance" "catalog" {
  identifier = "${var.environment_name}-catalog"

  engine         = "mysql"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp2"

  db_name  = "catalog"
  username = "catalog"
  password = random_string.catalog_db_master.result

  db_subnet_group_name = "project-bedrock-db-subnet-group"

  vpc_security_group_ids = concat(
    var.allowed_security_group_ids,
    [var.catalog_security_group_id]
  )

  backup_retention_period = 1

  multi_az            = false
  publicly_accessible = false

  apply_immediately   = true
  skip_final_snapshot = true
  deletion_protection = false

  lifecycle {
    ignore_changes = [
      storage_encrypted,
      username,
      password,
      db_subnet_group_name,
      vpc_security_group_ids,
      tags,
    ]
  }

  tags = var.tags
}

resource "random_string" "catalog_db_master" {
  length  = 10
  special = false
}
