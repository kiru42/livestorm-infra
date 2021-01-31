resource "aws_s3_bucket" "terraform-state" {
  bucket = local.common_tags["Name"]
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = local.common_tags
}
