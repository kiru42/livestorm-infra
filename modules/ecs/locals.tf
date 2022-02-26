locals {
  common_tags = {
    Name        = "${terraform.workspace}-${var.project}-${var.application}"
    Environment = terraform.workspace
    Project     = var.project
    Application = var.application
  }
}
