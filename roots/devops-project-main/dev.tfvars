# greeting    = "Hi"
# project     = "proshop"
environment = "dev"
vpc_id      = "vpc-0c0336612a59a2bcb"
private_subnet_ids = [
  "subnet-0594302c344487dcd",
  "subnet-0dccddffb0479e023",
  "subnet-0067a24f238d163f7"
]
eks_nodes_sg_id = "sg-0078aefc09d269a10"

role_name           = "cluster-autoscaler-irsa-v2"
serviceaccount_name = "cluster-autoscaler"
oidc_provider_arn   = "arn:aws:iam::340924313311:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/F4C0076A985F1F8B9116CC121C7BB92F"
oidc_provider_url   = "oidc.eks.us-east-1.amazonaws.com/id/F4C0076A985F1F8B9116CC121C7BB92F"

oidc_sub                  = "system:serviceaccount:kube-system:cluster-autoscaler"
project_name              = "312school-final-project"
vpc_cidr                  = "10.70.0.0/16"
public_subnet_cidrs       = ["10.70.1.0/24", "10.70.2.0/24", "10.70.3.0/24"]
private_subnet_cidrs      = ["10.70.11.0/24", "10.70.12.0/24", "10.70.13.0/24"]
availability_zones        = ["us-east-1a", "us-east-1c", "us-east-1f"]
k8s_version               = "1.32"
ec2_types                 = ["t3.medium", "t3a.medium", "t2.medium"]
workers_min               = 1
workers_max               = 5
workers_desired           = 3
sso_admin_role_arn        = "arn:aws:iam::340924313311:role/aws-reserved/sso.amazonaws.com/us-east-2/AWSReservedSSO_Administrator_f285af2e87635301"
github_ci_runner_role_arn = "arn:aws:iam::340924313311:role/GitHubActionsCICDrole"
github_tf_runner_role_arn = "arn:aws:iam::340924313311:role/GitHubActionsTerraformAndPlatformToolsIAMrole"

# oidc_provider_id          = "F4C0076A985F1F8B9116CC121C7BB92F"
# external_dns_sa_namespace = "public-helm-charts"
# external_dns_sa_name      = "external-dns"

# eks_resource_arns = ["arn:aws:eks:us-east-1:340924313311:cluster/temporary-eks-cluster-dev"] # Or provide exact ARNs if known
aws_account_id = "340924313311"

// ********** RDS Variabes **********
# multi_az                    = false
# versus_db_allocated_storage = 20
# cpu_threshold               = 10
# engine_version              = "8.0.42"
# mysql_parameter_group_name  = "default.mysql8.0"
# versus_db_instance_class    = "db.t3.micro"
# versus_db_username          = "versus_dev"
# rds_private_subnet_ids      = ["subnet-00c89359fca37f94c", "subnet-07979053439a5a7b8", "subnet-040413dbcaad2e2f1"]
# eks_security_group_ids      = ["sg-0078aefc09d269a10"]
# alert_email                 = "timur.dzh@edu.312school.com"
# versus_db_name              = "versusdb"