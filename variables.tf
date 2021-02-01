## Project variables

variable "project" {
  description = "Project Name (used to construct tags & ressource name)."
  type        = string
  default     = null
}

variable "application" {
  description = "Application Name (used to construct tags & ressource name)."
  type        = string
  default     = null
}

variable "region" {
  description = "Region Name where to deploy the ressources."
  type        = string
  default     = null
}

## VPC variables

variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  type        = string
  default     = "0.0.0.0/0"
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = []
}

## ECS variables

variable "ecs_min_instances" {
  description = "ASG max ECS instances."
  type        = string
  default     = null
}

variable "ecs_max_instances" {
  description = "ASG min ECS instances."
  type        = string
  default     = null
}

variable "ecs_desired_capacity" {
  description = "ASG desired ECS instances."
  type        = string
  default     = null
}

variable "ecs_instance_type" {
  description = "Instance type to be used with ECS."
  type        = string
  default     = null
}

variable "ecs_container_name" {
  description = "Container name for ECS."
  type        = string
  default     = null
}

variable "ecs_service_port" {
  description = "Service port to use."
  type        = string
  default     = null
}

## Route53 variables

variable "public_zone_id" {
  description = "The ID of the public Route 53 zone."
  type        = string
}

variable "domain_name" {
  description = "The domain name of the supplied Route 53 zones."
  type        = string
}

## ACM variables

variable "acm_arn" {
  description = "The ACM ARN for SSL Certificates."
  type        = string
}

## ALB variables

variable "allowed_cidrs_for_alb" {
  description = "A list of allowed cidrs for ALB"
  type        = list(string)
  default     = []
}
