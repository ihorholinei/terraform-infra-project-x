## Terraform IAM Read-Only Role for EKS

This module provisions a read-only AWS IAM role and policy that allows limited access to Amazon EKS clusters. It is designed to safely provide developers with view-only permissions without exposing sensitive resources like Secrets or enabling pod exec access.

---

## ✨ Features

- Creates an IAM role with a trust policy limited to your AWS account
- Attaches a custom policy with read-only EKS permissions
- Supports targeting specific EKS clusters using ARNs
- Configurable via variables for reuse across environments

---

## 📁 Structure

- `main.tf` — defines IAM role, policy, and attachment
- `variables.tf` — declares module inputs (e.g., `role_name`, `eks_cluster_arns`, etc.)
- `dev.tfvars` / `prod.tfvars` — environment-specific values

---

## ⚙️ Example Usage

```hcl
module "readonly_iam_role" {
  source            = "../../readonly-k8s-iamrole"
  role_name         = var.role_name
  eks_policy_name   = var.eks_policy_name
  eks_actions       = var.eks_actions
  eks_cluster_arns  = var.eks_cluster_arns
}



🚀 Deployment Steps
	1.	Set values in your dev.tfvars or prod.tfvars file.
	2.	Run:
             terraform init
             terraform plan -var-file="dev.tfvars"
             terraform apply -var-file="dev.tfvars"



📝 Notes
	•	You must manually map the IAM role to aws-auth ConfigMap in -n kube-system namespace in your EKS cluster.
    •   Also, you must create a ClusterRole and a ClusterRoleBinding inside the cluster.
    •	Do not grant access to secrets, pods/exec, or other sensitive actions to preserve least privilege.
    