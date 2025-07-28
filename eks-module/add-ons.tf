# EKS Add-ons (Networking & Storage)
resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = aws_eks_cluster.main_cluster.name
  addon_name                  = "vpc-cni"
  addon_version               = "v1.19.5-eksbuild.3"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name                = aws_eks_cluster.main_cluster.name
  addon_name                  = "aws-ebs-csi-driver"
  addon_version               = "v1.44.0-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  service_account_role_arn    = aws_iam_role.ebs_csi_irsa_role.arn
}

resource "aws_eks_addon" "coredns" {
  cluster_name                = aws_eks_cluster.main_cluster.name
  addon_name                  = "coredns"
  addon_version               = "v1.11.4-eksbuild.14"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = aws_eks_cluster.main_cluster.name
  addon_name                  = "kube-proxy"
  addon_version               = "v1.32.3-eksbuild.7"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}