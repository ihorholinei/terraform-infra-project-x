# EKS Cluster
resource "aws_eks_cluster" "main_cluster" {
  name     = local.cluster_name
  role_arn = aws_iam_role.eks_cluster_iam_role.arn
  version  = var.k8s_version

  vpc_config {
    subnet_ids             = var.public_subnet_ids
    security_group_ids     = [aws_security_group.cluster_sg.id]
    endpoint_public_access = true
  }

  enabled_cluster_log_types = ["api", "audit"]
  access_config {
    authentication_mode = "API"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy_attachment,
    aws_iam_role_policy_attachment.eks_service_policy_attachment
  ]

  tags = {
    "Name"                                        = local.cluster_name
    "project"                                     = var.project_name
    "environment"                                 = var.environment
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }
}

# Security Group for Control Plane
resource "aws_security_group" "cluster_sg" {
  vpc_id = var.vpc_id
  name   = "${local.cluster_name}-cluster-sg"

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.worker_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.cluster_name}-cluster-sg"
  }
}

# Security Group for Worker Nodes
resource "aws_security_group" "worker_sg" {
  vpc_id      = var.vpc_id
  name        = "${local.name_prefix}-worker-sg"
  description = "Allow worker node communication"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                                          = "${local.name_prefix}-worker-sg"
    project                                       = var.project_name
    environment                                   = var.environment
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }
}

resource "aws_security_group_rule" "node-to-node" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.worker_sg.id
  source_security_group_id = aws_security_group.worker_sg.id
  description              = "Allow all traffic from worker nodes to each other"
}

resource "aws_security_group_rule" "node-to-node-udp" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "udp"
  security_group_id        = aws_security_group.worker_sg.id
  source_security_group_id = aws_security_group.worker_sg.id
  description              = "Allow all UDP traffic between worker nodes"
}

resource "aws_security_group_rule" "worker_to_worker_dns_udp" {
  type              = "ingress"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  self              = true
  security_group_id = aws_security_group.worker_sg.id
  description       = "Allow DNS traffic (UDP)from other worker nodes (same SG) in the cluster"
}

resource "aws_security_group_rule" "worker_to_worker_dns_tcp" {
  type              = "ingress"
  from_port         = 53
  to_port           = 53
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.worker_sg.id
  description       = "Allow DNS traffic (TCP)from other worker nodes (same SG) in the cluster"
}

resource "aws_security_group_rule" "internal_kubelet_access" {
  type              = "ingress"
  from_port         = 10250
  to_port           = 10250
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.worker_sg.id
  description       = "Allow access to kubelet from within the VPC (for Prometheus, Metrics Server, etc.)"
}

resource "aws_security_group_rule" "allow_control_plane_to_kubelet" {
  type                     = "ingress"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  security_group_id        = aws_security_group.worker_sg.id
  source_security_group_id = aws_security_group.cluster_sg.id
  description              = "Allow EKS control plane to communicate with kubelet on worker nodes (for exec/logs/health checks)"
}

# EKS Optimized AMI for Worker Nodes
data "aws_ssm_parameter" "eks_worker_ami" {
  name = "/aws/service/eks/optimized-ami/1.32/amazon-linux-2/recommended/image_id"
}

resource "aws_iam_instance_profile" "worker_nodes_instance_profile" {
  name = "${local.name_prefix}-instance-profile"
  role = aws_iam_role.worker_nodes_iam_role.name
}

resource "aws_launch_template" "worker_nodes_launch_template" {
  name                   = "${local.name_prefix}-launch-template"
  image_id               = data.aws_ssm_parameter.eks_worker_ami.value
  vpc_security_group_ids = [aws_security_group.worker_sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.worker_nodes_instance_profile.name
  }

  user_data = base64encode(<<-EOT
    #!/bin/bash
    set -o xtrace
    /etc/eks/bootstrap.sh ${local.cluster_name} \
      --apiserver-endpoint '${aws_eks_cluster.main_cluster.endpoint}' \
      --b64-cluster-ca '${aws_eks_cluster.main_cluster.certificate_authority[0].data}' \
      --kubelet-extra-args '--node-labels=node.kubernetes.io/lifecycle=normal'
  EOT
  )

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name                                          = "${local.cluster_name}-node"
      project                                       = var.project_name
      environment                                   = var.environment
      "kubernetes.io/cluster/${local.cluster_name}" = "owned"
    }
  }

  tag_specifications {
    resource_type = "network-interface"
    tags = {
      "kubernetes.io/cluster/${local.cluster_name}" = "owned"
    }
  }
}