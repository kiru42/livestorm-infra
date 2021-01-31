resource "aws_dynamodb_table" "terraform-state-lock" {
  name           = local.common_tags["Name"]
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = local.common_tags
}
