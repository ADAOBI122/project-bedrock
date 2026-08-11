resource "aws_dynamodb_table" "carts" {

  name = "project-bedrock-carts"

  billing_mode = "PAY_PER_REQUEST"


  hash_key = "id"


  attribute {

    name = "id"

    type = "S"

  }


  tags = {

    Project = "tinyuka-2025-capstone"

  }

}
