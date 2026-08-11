resource "aws_s3_bucket" "assets" {
  bucket = "bedrock-assets-alt-soe-tin-025-0061"

  tags = {
    Name    = "bedrock-assets-alt-soe-tin-025-0061"
    Project = "tinyuka-2025-capstone"
  }
}

resource "aws_s3_bucket_public_access_block" "assets" {
  bucket = aws_s3_bucket.assets.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}
