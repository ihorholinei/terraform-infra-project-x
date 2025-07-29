
# DO NOT REMOVE DUMMY MODULE references and their code, they should remain as examples
# module "module1" {
#   source = "../../dummy-module-1"
#   # ... any required variables for module1
#   greeting = var.greeting

# }

# module "module2" {
#   source             = "../../dummy-module-2"
#   input_from_module1 = module.module1.greeting_message
#   # ... any other required variables for module2
# }


module "cluster_autoscaler_irsa" {
  # count               = var.enable_condition ? 1 : 0
  source              = "../../autoscaler-module"
  role_name           = var.role_name
  serviceaccount_name = var.serviceaccount_name
  oidc_provider_arn   = var.oidc_provider_arn
  oidc_provider_url   = var.oidc_provider_url
  oidc_sub            = var.oidc_sub
  aws_account_id      = var.aws_account_id

}

# module "proshop_documentdb" {
#   count           = var.enable_condition ? 1 : 0
#   source          = "../../documentdb-module"
#   project         = var.project
#   environment     = var.environment
#   vpc_id          = var.vpc_id
#   subnet_ids      = var.private_subnet_ids
#   eks_nodes_sg_id = var.eks_nodes_sg_id
# }

# moved {
#   from = module.proshop_documentdb
#   to   = module.proshop_documentdb[0]
# }


# module "readonly_iam_role" {
#   count             = var.enable_condition ? 1 : 0
#   source            = "../../readonly-k8s-iamrole"
#   eks_resource_arns = var.eks_resource_arns
#   aws_account_id    = var.aws_account_id
# }

# moved {
#   from = module.readonly_iam_role
#   to   = module.readonly_iam_role[0]
# }


module "vpc" {
  # count                = var.enable_condition ? 1 : 0
  source               = "../../vpc-module"
  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

# moved {
#   from = module.vpc
#   to   = module.vpc[0]
# }



module "eks" {
  # count                     = var.enable_condition ? 1 : 0
  source                    = "../../eks-module"
  project_name              = var.project_name
  environment               = var.environment
  vpc_id                    = module.vpc[0].vpc_id
  vpc_cidr                  = var.vpc_cidr
  public_subnet_ids         = module.vpc[0].public_subnet_ids
  k8s_version               = var.k8s_version
  ec2_types                 = var.ec2_types
  workers_min               = var.workers_min
  workers_max               = var.workers_max
  workers_desired           = var.workers_desired
  sso_admin_role_arn        = var.sso_admin_role_arn
  github_ci_runner_role_arn = var.github_ci_runner_role_arn
  github_tf_runner_role_arn = var.github_tf_runner_role_arn
}

# moved {
#   from = module.eks
#   to   = module.eks[0]
# }