
# Let's create S3 bucket and dynamodb for tfstates

module "livestorm-tf-states" {
  source = "../../modules/terraform-state"
  prefix = "${terraform.workspace}-livestorm"
}

# Create ECS module


