######################################################################
### DATA

# Gather some data about execution context -

data "aws_organizations_organization" "this" {}

data "aws_region" "current" {}

locals {
  root_account_id = data.aws_organizations_organization.this.master_account_id

  log_archive_account_id = var.account_params.log_archive_account_id

  security_account_id = var.account_params.security_account_id

  aws_region = data.aws_region.current.name
}

#---------------------------------------------------------------------
### ACCOUNT / REGION LOCALS:

# Identify accounts with unique responsibilities/resources:

locals {
  # root (Owns the org's CloudTrail trail)
  IS_ROOT_ACCOUNT = var.account_params.id == local.root_account_id

  # Log-Archive (Owns the S3 to which all logs are sent/aggregated)
  IS_LOG_ARCHIVE_ACCOUNT = var.account_params.id == local.log_archive_account_id

  # Security (Master GuardDuty account)
  IS_SECURITY_ACCOUNT = var.account_params.id == local.security_account_id
}

######################################################################
