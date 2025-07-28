# 🌐 Amazon EKS Infrastructure with GitOps - Final Project

This project delivers a fully automated Amazon EKS cluster using a modular Terraform architecture, integrated with GitHub Actions to enforce GitOps principles. The infrastructure is designed to be secure, cost-effective, scalable, and environment-aware (dev/staging/prod).

All components of the infrastructure — from VPC to EKS add-ons and Ingress Controller — are created declaratively via version-controlled Terraform code, with CI/CD workflows as the only interface to AWS. No manual 'terraform apply` is run from local.

Security, scalability, and GitOps automation are foundational principles of this deployment.

---

## 📦 Project Features

* **Modular Design:**
  * Separate Terraform modules for VPC and EKS
  * Reusable across environments (dev, staging, prod)

* **GitOps Execution:**
  * GitHub Actions runs all Terraform commands
  * Role-based access with OIDC integration
  * Uses `dev.tfvars` for environment-specific configuration

* **Self-Managed Node Group:**
  * Auto Scaling Group with Launch Template
  * Mixed instance types with 80% Spot, 20% On-Demand
  * Minimum 1, Desired 3, Maximum 5 nodes

* **Networking:**
  * Custom VPC with 3 public + 3 private subnets
  * Public subnets host both control plane and worker nodes
  * Private subnets reserved for future RDS integration
  * Explicit routing tables and Internet Gateway configuration

* **Secure IAM & EKS Access Entries:**
  * SSO Admin role access
  * GitHub CI/CD and Terraform roles via `aws_eks_access_entry`
  * Avoids deprecated `aws-auth` ConfigMap

* **EKS Add-Ons:**
  * VPC CNI
  * CoreDNS
  * Kube Proxy
  * EBS CSI (for dynamic volume provisioning)

* **Ingress Controller:**
  * Helm-installed NGINX with LoadBalancer service type
  * Triggered post-node-readiness in CI pipeline
  * ELB exposed and ready for service routing
  
* **State Management:**
  * Remote state in S3 with DynamoDB locking

---

## 📁 File & Module Structure

terraform-infra-24c-redhat/
├── .github/workflows/             # GitHub Actions CI/CD workflows
├── eks-module/                    # Custom EKS Terraform module
│   ├── add-ons.tf
│   ├── eks-cluster.tf
│   ├── iam.tf
│   ├── locals.tf
│   ├── nodes-asg.tf
│   ├── oidc-provider.tf
│   ├── outputs.tf
│   ├── README.md                   # You're here
│   ├── ssm.tf
│   └── variables.tf
├── roots/                          # Root module for multi-env configuration
│   └── devops-project-main/ 
│       ├── dev.tfvars
│       ├── main.tf
│       ├── outputs.tf
│       ├── production.tfvars
│       ├── providers.tf
│       ├── staging.tfvars
│       └── variables.tf
├── vpc-module/                      # Custom VPC Terraform module
│   ├── locals.tf
│   ├── outputs.tf
│   ├── resources.tf
│   └── variables.tf
├── .gitignore

---

## 🛠️ Infrastructure Created

* Custom VPC (CIDR, subnets, route tables, internet gateway)
* Public and private subnets across 3 AZs
* EKS cluster with Kubernetes version 1.32
* Auto Scaling Group for worker nodes with mixed spot/on-demand strategy
* IAM roles and instance profile for control plane and nodes
* EKS Add-ons: CoreDNS, kube-proxy, VPC CNI, EBS CSI
* EKS Access Entries (SSO, CI/CD, Terraform roles)
* Helm-based Ingress NGINX controller with LoadBalancer service
* SSM Parameter for cluster name

---
## 🧪 Common Issues & Troubleshooting

### ❌ Worker Nodes Not Joining the EKS Cluster

**Symptom:** `kubectl get nodes` → `No resources found`

Even though the Auto Scaling Group launched EC2 instances (worker nodes), they were not registering with the cluster.

**Root Cause:**

User data misconfiguration in the launch template — the bootstrap.sh script was missing or improperly formatted

Missing IAM role permissions — the worker node role lacked one or more required managed policies

EKS Access Entry misconfiguration — node role was not granted access to join the cluster

Security group misconfiguration — control plane security group couldn't reach worker nodes

**Fix:**

Used EKS bootstrap script in user_data:

/etc/eks/bootstrap.sh <cluster_name> \
  --apiserver-endpoint '<endpoint>' \
  --b64-cluster-ca '<certificate-authority>' \
  --kubelet-extra-args '--node-labels=node.kubernetes.io/lifecycle=normal'

- Attached required IAM policies to the worker node role:
- AmazonEKSWorkerNodePolicy
- AmazonEC2ContainerRegistryReadOnly
- AmazonEKS_CNI_Policy

Created proper EKS Access Entry for the node role using:

resource "aws_eks_access_entry" "nodes" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = aws_iam_role.eks_nodes.arn
  type          = "EC2_LINUX"
}

The EKS control plane security group (cluster_sg) is allowing inbound traffic on:

Port 443 (Kubernetes API server — used by kubelet on nodes to register, sync, etc.)

---

### ❌ DNS Resolution Failing with NXDOMAIN Errors

**Symptom:** Pods could not resolve internal DNS names like `kubernetes.default`.

**Root Cause:**
VPC settings were missing DNS support options. Without `enable_dns_support` and `enable_dns_hostnames`, CoreDNS fails.

**Fix:**
Set the following in your VPC module:

```hcl
enable_dns_support   = true
enable_dns_hostnames = true
```

Once redeployed, DNS resolution worked as expected.

---

### ❌ NGINX Ingress LoadBalancer EXTERNAL-IP Pending

**Symptom:** `kubectl get svc -n ingress-nginx` shows `EXTERNAL-IP = <pending>`

**Root Cause:** Public subnets were missing required Kubernetes subnet discovery tags.

**Fix:**
Add these subnet tags via Terraform:

```hcl
"kubernetes.io/cluster/<cluster-name>" = "shared"
"kubernetes.io/role/elb"               = "1"
```

After applying, the LoadBalancer ELB was created and assigned a public IP.

---

## Validation Checklist

✅ Terraform plan and apply complete successfully via GitHub Actions
✅ VPC created with correct CIDR, subnets, internet gateway, and route tables
✅ Public subnets host control plane and worker nodes with required tags
✅ SSO Administrator and GitHub roles configured via EKS Access Entries
✅ EKS cluster created using version 1.32
✅ Worker nodes provisioned across 3 AZs with correct spot/on-demand ratio
✅ EKS add-ons deployed and confirmed (CoreDNS, kube-proxy, VPC CNI, EBS CSI)
✅ Nodes successfully register with EKS and appear via kubectl get nodes
✅ Ingress NGINX controller installed via Helm with ELB assigned
✅ Remote Terraform state stored in S3 with DynamoDB locking

## 📙 Documentation & References

* [Terraform AWS Provider Docs] (https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster)
* [Amazon EKS Official Docs]    (https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html)
* [Helm Charts - Ingress NGINX] (https://kubernetes.github.io/ingress-nginx/deploy/#quick-start)
* [EKS Access Entries]          (https://docs.aws.amazon.com/eks/latest/userguide/access-entries.html)
* [EKS Add-ons Documentation]   (https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html)

---

# Amazon EKS Infrastructure - Final Project

This project provisions a fully functional, GitOps-compliant Amazon EKS cluster using Terraform and GitHub Actions. The cluster is deployed in a custom-built VPC using self-managed worker nodes, with Ingress NGINX for external access. All infrastructure is modularized into separate VPC and EKS Terraform modules.