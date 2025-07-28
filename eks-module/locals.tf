locals {
  cluster_name = "${var.project_name}-${var.environment}-eks"
  name_prefix  = "${var.project_name}-${var.environment}"
}