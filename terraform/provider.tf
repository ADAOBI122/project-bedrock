provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project = "tinyuka-2025-capstone"
    }
  }
}
