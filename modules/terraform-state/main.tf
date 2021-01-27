variable "prefix" {
  type    = string
  default = "livestorm-dev"
}

data "aws_region" "current" {}


resource "aws_s3_bucket" "terraform-state" {
  bucket = "${var.prefix}-tf-states"
  acl    = "private"
  #region = data.aws_region.current.name

  versioning {
    enabled = true
  }

  tags = {
    Name = var.prefix
  }
}

resource "aws_dynamodb_table" "terraform-state-lock" {
  name           = "${var.prefix}-terraform-state-lock"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
