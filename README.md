# LiveStorm on ECS

We are going to migrate LiveStorm on ECS.

LiveStorm is a monolithic application built on Rails : responding `Hello world` on GET `/`

We will be creating the infrastruction on AWS using Terraform. 

# Requirements

We will be using :
- Terraform version : 0.14.5

# Infrastructure

We will create a Dockerfile with fixed terraform & providers versions for sharing the tools between DevOps instead of installing stuff locally.

Here are the modules we will be ceating for terraform :

- a module to manage terraform states (S3 as backend for tf states + DynamoDb for tf lock)
- a module to create an ECS cluster along an ECR repository for pushing docker images
- a module to create ECS service : service & task definition
- a module to create a load balancer, here an ELB with ACM and route53 entry

We will use the following offial modules for these needs :

- terraform-aws-modules/vpc/aws for creating VPC
- terraform-aws-modules/autoscaling/aws for creating ASG

Things managed manually for testing purpose, could be terraformed if needed :
- Route53 public zone
- ACM certificate

Then we will configure a rails application with github actions to build and deploy

# Running docker with infra tools

```bash
# let's build the docker with all tools

docker build -t livestorm-terraform-workspace .

docker run -it -v "$(pwd)":/livestorm -v "$(pwd)/.aws":/root/.aws livestorm-terraform-workspace bash
```

# Using terraform inside docker container

```bash
cd projects/livestorm

# for dev
terraform workspace select dev
terraform init && terraform plan
terraform apply # if everything seems fine to you
```

if you don't have access_key/secret_key configured for aws, you can open the following file (`projects/livestorm/provider.tf`) and copy paste this for testing the plan :

```tf
provider "aws" {
  #profile = "default"
  region = "eu-west-1"
  #region                      = "${var.region}"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  s3_force_path_style         = true
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"

  endpoints {
    dynamodb = "http://localhost:4569"
    s3       = "http://localhost:4572"
  }
}
```

# Using workspace for different environment

```
terraform workspace new dev
terraform workspace new qa
terraform workspace new staging
terraform workspace new prod
terraform workspace select dev
```