terraform {
  backend "s3" {
    bucket       = "project-bedrock-tf-state-206362095513"
    key          = "project-bedrock/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}
