######################################################################
### DATA

# Gather some data about execution context -

data "aws_organizations_organization" "this" {}

data "aws_region" "current" {}

locals {
  ROOT_ACCOUNT_ID = data.aws_organizations_organization.this.master_account_id
  aws_region      = data.aws_region.current.name
}

#---------------------------------------------------------------------
### ACCOUNT / REGION LOCALS:

# Identify accounts with unique responsibilities/resources:

locals {
  # root (Owns the org's CloudTrail trail)
  IS_ROOT_ACCOUNT = var.account_params.id == local.ROOT_ACCOUNT_ID

  # Log-Archive (Owns the S3 to which all logs are sent/aggregated)
  IS_LOG_ARCHIVE_ACCOUNT = var.account_params.is_log_archive_account == true
}

######################################################################
