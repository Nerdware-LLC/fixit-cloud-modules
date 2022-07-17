######################################################################
### DATA

data "aws_organizations_organization" "this" {}

data "aws_caller_identity" "current" {}

locals {
  # Gather relevant IDs
  org_id            = data.aws_organizations_organization.this.id
  caller_account_id = data.aws_caller_identity.current.account_id

  # root (Owns the org's CloudTrail trail)
  root_account_id = data.aws_organizations_organization.this.master_account_id

  # Create a list of all account IDs to be used in several service-linked role policies
  all_account_ids = data.aws_organizations_organization.this.accounts[*].id

  /* The purpose of the locals below is simply to clarify the intent
  of count-meta-args in conditionally-created resources */
  IS_ROOT_ACCOUNT = local.caller_account_id == local.root_account_id
}

######################################################################
