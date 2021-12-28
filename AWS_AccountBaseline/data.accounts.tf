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
  caller_account_id = data.aws_caller_identity.current.account_id

  # root (Owns the org's CloudTrail trail)
  root_account_id = data.aws_organizations_organization.this.master_account_id

  # Log-Archive (Owns the S3 to which all logs are sent/aggregated)
  log_archive_account_id = one([
    for account in values(var.accounts) : account.id
    if lookup(account, "is_log_archive_account", false) == true
  ])

  # Security (Master GuardDuty account)
  security_account_id = one([
    for account in values(var.accounts) : account.id
    if lookup(account, "is_security_account", false) == true
  ])

  # Create a list of all account IDs to be used in several service-linked role policies
  all_account_ids = values(var.accounts)[*].id

  /* The purpose of the locals below is simply to clarify the intent
  of count-meta-args in conditionally-created resources */
  IS_ROOT_ACCOUNT        = local.caller_account_id == local.root_account_id
  IS_LOG_ARCHIVE_ACCOUNT = local.caller_account_id == local.log_archive_account_id
  IS_SECURITY_ACCOUNT    = local.caller_account_id == local.security_account_id
}

######################################################################
