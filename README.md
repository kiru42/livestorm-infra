# LiveStorm on EKS

We are going to migrate LiveStorm on EKS.

LiveStorm is a wep application with a frontend in vuejs and a backend in Rails.

We will be creating the infrastruction on AWS using Terraform. 

# Infrastructure

We will create a Dockerfile with fixed terraform & providers versions for sharing the tools between DevOps instead of installing stuff locally.

Here are the modules we will be ceating :

- a module to manage terraform states
- a module to create an EKS cluster
- a module to create a RDS Aurora
- a module to create an ElasticCache (Redis)
- a module to create a S3 bucket
- a module to create a cloudfront distribution for frontend & statics contents

