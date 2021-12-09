######################################################################
### DATA

/* These data blocks and locals ascertain some info on the execution
context, such as the aws_region and caller account_id. account_id is
then used to determine if caller is an account with unique/Org-wide
resources and responsibilities.   */

data "aws_organizations_organization" "this" {}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  aws_region = data.aws_region.current.name

  root_account_id        = data.aws_organizations_organization.this.master_account_id
  log_archive_account_id = var.account_params.log_archive_account_id
  security_account_id    = var.account_params.security_account_id

  # root (Owns the org's CloudTrail trail)
  IS_ROOT_ACCOUNT = data.aws_caller_identity.account_id == local.root_account_id

  # Log-Archive (Owns the S3 to which all logs are sent/aggregated)
  IS_LOG_ARCHIVE_ACCOUNT = data.aws_caller_identity.account_id == local.log_archive_account_id

  # Security (Master GuardDuty account)
  IS_SECURITY_ACCOUNT = data.aws_caller_identity.account_id == local.security_account_id
}

######################################################################
