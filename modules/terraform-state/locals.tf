locals {
  component = "terraform-state"
  common_tags = {
    Name        = "${terraform.workspace}-${var.project}-${var.application}-${local.component}"
    Environment = terraform.workspace
    Project     = var.project
    Application = var.application
    Component   = local.component
  }
}
