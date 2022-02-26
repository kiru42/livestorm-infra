###################
##   RESSOURCES   #
###################

# ECR repository for storing docker images
resource "aws_ecr_repository" "ecr" {
  name = local.common_tags["Name"]

  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = local.common_tags
}
