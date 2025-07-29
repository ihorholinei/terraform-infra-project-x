output "eks_cluster_name" {
  value = length(module.eks) > 0 ? module.eks[0].cluster_name : ""
}

output "eks_endpoint" {
  value = length(module.eks) > 0 ? module.eks[0].cluster_endpoint : ""
}

output "autoscaler_role_arn" {
  value       = length(module.cluster_autoscaler_irsa) > 0 ? module.cluster_autoscaler_irsa[0].autoscaler_role_arn : null
  description = "ARN of the IRSA role for the Cluster Autoscaler"
}

output "eks_oidc_provider_url" {
  description = "OIDC Provider URL from EKS module for IRSA"
  value       = length(module.eks) > 0 ? module.eks[0].eks_oidc_provider_url : ""
}

# output "db_endpoint" {
#   description = "The endpoint URL of the RDS database instance provisioned by the versus_mysql module"
#   value       = length(module.versus_mysql) > 0 ? module.versus_mysql[0].db_instance_endpoint : null
# }
# output "cloudwatch_alarm_name" {
#   description = "The name of the CloudWatch alarm for high CPU utilization, created by the rds_cpu_alarm module"
#   value       = length(module.rds_cpu_alarm) > 0 ? module.rds_cpu_alarm[0].cpu_alarm_name : null
# }
# output "sns_topic_arn" {
#   description = "The ARN of the SNS topic used for CloudWatch alarm notifications, created by the rds_cpu_alarm module"
#   value       = length(module.rds_cpu_alarm) > 0 ? module.rds_cpu_alarm[0].sns_topic_arn : null
# }