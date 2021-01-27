# LiveStorm on EKS

We are going to migrate LiveStorm on EKS.

LiveStorm is a wep application with a frontend in vuejs and a backend in Rails.

We will be creating the infrastruction on AWS using Terraform. 

# Requirements

We will be using :
- Terraform version : 0.14.5
- Amazon EKS platform version : eks.3
- Kubernetes version : 1.18.9

# Infrastructure

We will create a Dockerfile with fixed terraform & providers versions for sharing the tools between DevOps instead of installing stuff locally.

Here are the modules we will be ceating for terraform :

- a module to manage terraform states (S3 as backend for tf states + DynamoDb for tf lock)
- a module to create an EKS cluster
- a module to create a RDS Aurora
- a module to create an ElasticCache (Redis)
- a module to create a S3 bucket
- a module to create a cloudfront distribution for frontend & statics contents

# Running docker with infra tools

```bash
# let's build the docker with all tools

docker build -t livestorm-terraform-workspace .

docker run -it -v "$(pwd)":/livestorm -v "$(pwd)/.kube":/root/.kube -v "$(pwd)/.aws":/root/.aws livestorm-terraform-workspace bash
```