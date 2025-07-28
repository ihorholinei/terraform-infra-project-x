#IAM Role for EKS Control Plane (Cluster)
resource "aws_iam_role" "eks_cluster_iam_role" {
  name = "${local.cluster_name}-cluster-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
  role       = aws_iam_role.eks_cluster_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_service_policy_attachment" {
  role       = aws_iam_role.eks_cluster_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}


# IAM Role for Worker Nodes
resource "aws_iam_role" "worker_nodes_iam_role" {
  name = "${local.cluster_name}-worker-nodes-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "worker_node_policy_attachment" {
  role       = aws_iam_role.worker_nodes_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "cni_policy_attachment" {
  role       = aws_iam_role.worker_nodes_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ecr_readonly_policy_attachment" {
  role       = aws_iam_role.worker_nodes_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "elb_policy_attachment" {
  role       = aws_iam_role.worker_nodes_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
}

resource "aws_iam_policy" "describe_self_policy" {
  name        = "${local.cluster_name}-describe-self-policy"
  path        = "/"
  description = "Allow nodes to describe themselves"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["ec2:DescribeInstances"],
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "describe_self_policy_attachment" {
  role       = aws_iam_role.worker_nodes_iam_role.name
  policy_arn = aws_iam_policy.describe_self_policy.arn
}


# EKS Access Entries
resource "aws_eks_access_entry" "nodes_entry" {
  cluster_name  = aws_eks_cluster.main_cluster.name
  principal_arn = aws_iam_role.worker_nodes_iam_role.arn
  type          = "EC2_LINUX"
}

resource "aws_eks_access_entry" "sso_admin_entry" {
  cluster_name  = aws_eks_cluster.main_cluster.name
  principal_arn = var.sso_admin_role_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin_access_policy_association" {
  cluster_name  = aws_eks_cluster.main_cluster.name
  principal_arn = var.sso_admin_role_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_entry" "github_tf_entry" {
  cluster_name  = aws_eks_cluster.main_cluster.name
  principal_arn = var.github_tf_runner_role_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "github_tf_access_policy_association" {
  cluster_name  = aws_eks_cluster.main_cluster.name
  principal_arn = var.github_tf_runner_role_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.github_tf_entry]
}

resource "aws_eks_access_entry" "github_ci_entry" {
  cluster_name  = aws_eks_cluster.main_cluster.name
  principal_arn = var.github_ci_runner_role_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "github_ci_access_policy_association" {
  cluster_name  = aws_eks_cluster.main_cluster.name
  principal_arn = var.github_ci_runner_role_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type       = "namespace"
    namespaces = ["cicd-namespace"]
  }

  depends_on = [aws_eks_access_entry.github_ci_entry]
}

#IAM Role for EBS CSI Driver
resource "aws_iam_role" "ebs_csi_irsa_role" {
  name = "${local.cluster_name}-ebs-csi-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = aws_iam_openid_connect_provider.eks_oidc_provider.arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${replace(aws_iam_openid_connect_provider.eks_oidc_provider.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ebs_csi_irsa_policy" {
  role       = aws_iam_role.ebs_csi_irsa_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}