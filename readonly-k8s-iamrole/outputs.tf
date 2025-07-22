output "role_name" {
  value = aws_iam_role.developer_readonly.name
}

output "policy_arn" {
  value = aws_iam_policy.eks_readonly.arn
}