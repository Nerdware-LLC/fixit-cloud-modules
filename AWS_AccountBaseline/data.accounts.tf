######################################################################
### DATA

/* These data blocks and locals ascertain account info, which is
used to determine whether or not the caller is an account with
unique/Org-wide resources and responsibilities.  */

data "aws_organizations_organization" "this" {}

data "aws_caller_identity" "current" {}

locals {
  # Gather relevant IDs
  org_id            = data.aws_organizations_organization.this.id
  root_account_id   = data.aws_organizations_organization.this.master_account_id
  caller_account_id = data.aws_caller_identity.current.account_id

  # ARNs for cross-account perms in IAM policies
  root_account_arn        = "arn:aws:iam::${local.root_account_id}:root"
  log_archive_account_arn = "arn:aws:iam::${var.log_archive_account_id}:root"

  # root (Owns the org's CloudTrail trail)
  IS_ROOT_ACCOUNT = local.caller_account_id == local.root_account_id

  # Log-Archive (Owns the S3 to which all logs are sent/aggregated)
  IS_LOG_ARCHIVE_ACCOUNT = local.caller_account_id == var.log_archive_account_id

  # Security (Master GuardDuty account)
  IS_SECURITY_ACCOUNT = local.caller_account_id == var.security_account_id
}

######################################################################
