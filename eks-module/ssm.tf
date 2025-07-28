resource "aws_ssm_parameter" "eks_cluster_name" {
  name  = "/infra/eks/cluster-name"
  type  = "String"
  value = aws_eks_cluster.main_cluster.name
}