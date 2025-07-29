# Use existing OIDC provider (created during bootstrap)
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

# Create proper GitHub Actions roles
resource "aws_iam_role" "github_terraform_runner" {
  name = "GitHubActionsTerraformAndPlatformToolsIAMrole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = data.aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:dennis-ihor/terraform-infra-project-x:*"
        }
      }
    }]
  })
}

resource "aws_iam_role" "github_cicd_runner" {
  name = "GitHubActionsCICDrole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = data.aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:dennis-ihor/terraform-infra-project-x:*"
        }
      }
    }]
  })
}

# Attach existing policies or create new ones as needed
resource "aws_iam_role_policy_attachment" "terraform_admin" {
  role       = aws_iam_role.github_terraform_runner.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role_policy_attachment" "cicd_limited" {
  role       = aws_iam_role.github_cicd_runner.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
} 