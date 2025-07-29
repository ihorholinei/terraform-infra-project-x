# Note: S3 bucket is created manually to prevent accidental deletion during terraform destroy
# The bucket name should be: ${AWS_ACCOUNT_ID}-project-x-state-bucket-den-iho-${ENVIRONMENT_STAGE}

# Note: DynamoDB table is created manually to prevent accidental deletion during terraform destroy
# The table name should be: terraform-locks-${ENVIRONMENT_STAGE}

# Get current AWS account ID
# data "aws_caller_identity" "current" {} 