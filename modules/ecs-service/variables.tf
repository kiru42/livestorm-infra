variable "cluster_id" {
  description = "The ECS cluster ID"
  type        = string
}

variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = null
}

variable "region" {
  description = "Region to be used as default if not overide"
  type        = string
  default     = "eu-west-1"
}

variable "target_group_arn" {
  description = "Target Group ARN."
  type        = string
  default     = null
}

variable "container_name" {
  description = "Container name to be used."
  type        = string
  default     = null
}
