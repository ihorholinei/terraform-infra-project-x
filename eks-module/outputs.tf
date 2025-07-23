output "cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.main.id
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = aws_eks_cluster.main.arn
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.main.name
}

output "cluster_version" {
  description = "EKS cluster version"
  value       = aws_eks_cluster.main.version
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group for EKS nodes"
  value       = aws_autoscaling_group.eks_nodes.name
}

output "launch_template_id" {
  description = "ID of the launch template for EKS nodes"
  value       = aws_launch_template.eks_nodes.id
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_security_group.eks_cluster_sg.id
}

output "node_security_group_id" {
  description = "Security group ID attached to the EKS nodes"
  value       = aws_security_group.eks_nodes_sg.id
}

output "cluster_iam_role_name" {
  description = "IAM role name for the EKS cluster"
  value       = aws_iam_role.eks_cluster_role.name
}

output "node_iam_role_name" {
  description = "IAM role name for the EKS nodes"
  value       = aws_iam_role.eks_node_role.name
}

output "node_iam_instance_profile_name" {
  description = "IAM instance profile name for the EKS nodes"
  value       = aws_iam_instance_profile.eks_node_profile.name
} 