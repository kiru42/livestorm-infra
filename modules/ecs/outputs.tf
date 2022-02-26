output "ecs_iam_instance_profile_id" {
  description = "ID of the IAM instance profile"
  value       = aws_iam_instance_profile.ecs_instance_profile.id
}

output "ecs_iam_role_id" {
  description = "ID of the IAM role"
  value       = aws_iam_role.ecs_instance_role.id
}
