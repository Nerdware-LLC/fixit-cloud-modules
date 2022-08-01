######################################################################
### DATA

/* These data blocks and locals ascertain account info, which is
used to determine whether or not the caller is an account with
unique/Org-wide resources and responsibilities.  */

data "aws_organizations_organization" "this" {}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  # Gather relevant IDs
  caller_account_id = data.aws_caller_identity.current.account_id

  # root (Owns the org's CloudTrail trail)
  root_account_id = data.aws_organizations_organization.this.master_account_id

  /* The purpose of the locals below is simply to clarify the intent
  of count-meta-args in conditionally-created resources */
  IS_ROOT_ACCOUNT = local.caller_account_id == local.root_account_id

  aws_region = data.aws_region.current.name
}

######################################################################
