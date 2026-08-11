locals {
  retail_store_services = [
    "retail-store-cart",
    "retail-store-catalog",
    "retail-store-orders",
    "retail-store-load-generator",
    "retail-store-ui",
    "retail-store-checkout"
  ]
}

resource "aws_ecr_repository" "retail_store" {
  for_each = toset(local.retail_store_services)

  name                 = each.key
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project   = "project-bedrock"
    ManagedBy = "terraform"
    Service   = each.key
  }
}

output "ecr_repository_urls" {
  value = {
    for service, repository in aws_ecr_repository.retail_store :
    service => repository.repository_url
  }
}
