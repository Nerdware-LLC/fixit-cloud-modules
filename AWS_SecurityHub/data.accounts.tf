######################################################################
### DATA

/* These data blocks and locals ascertain account info, which is
used to determine whether or not the caller is an account with
unique/Org-wide resources and responsibilities.  */

data "aws_caller_identity" "current" {}

data "aws_organizations_organization" "this" {}

locals {
  /* The purpose of the locals below is simply to clarify the intent
  of count-meta-args in conditionally-created resources */
  IS_ROOT_ACCOUNT = (
    data.aws_caller_identity.current.account_id == data.aws_organizations_organization.this.master_account_id
  )

  IS_SECURITYHUB_ADMIN_ACCOUNT = var.securityhub_member_accounts != null
}

######################################################################
