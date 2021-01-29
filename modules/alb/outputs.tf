output "name" {
  description = "The name of the created ALB."
  value       = aws_lb.alb.name
}

output "arn" {
  description = "The ARN of the created ALB."
  value       = aws_lb.alb.arn
}

output "arn_suffix" {
  description = "The ARN suffix of the created ALB."
  value       = aws_lb.alb.arn_suffix
}

output "zone_id" {
  description = "The zone ID of the created ALB."
  value       = aws_lb.alb.zone_id
}

output "dns_name" {
  description = "The DNS name of the created ALB."
  value       = aws_lb.alb.dns_name
}

output "address" {
  description = "The name of the service DNS record."
  value       = "${var.name}.${var.domain_name}"
}

output "security_group_id" {
  description = "The ID of the security group associated with the ALB."
  value       = aws_security_group.load_balancer.id
}

output "open_to_load_balancer_security_group_id" {
  description = "The ID of the security group allowing access from the ALB."
  value       = aws_security_group.open_to_load_balancer.id
}

output "target_group_arn" {
  description = "The ARN of the target group."
  value       = aws_lb_target_group.target_group.arn
}
