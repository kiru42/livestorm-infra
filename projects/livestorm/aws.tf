
# Let's create S3 bucket and dynamodb for tfstates

module "livestorm-tf-states" {
  source = "../../modules/terraform-state"
  prefix = "${terraform.workspace}-livestorm"
}

# todo : create Aurora

# todo : create S3 bucket for static contents

# todo : create EKS module

# todo : create 
