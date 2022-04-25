######################################################################
### SecurityHub
#---------------------------------------------------------------------
### SecurityHub Delegated Administrator

/* The admin can add/rm member accounts, and view/update member findings.
Members must subscribe to standards/controls on their own, however.  */

resource "aws_securityhub_organization_admin_account" "Org_Admin_Account" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  admin_account_id = var.securityhub_organization_admin_account_id
}

#---------------------------------------------------------------------
### SecurityHub Organization Config

resource "aws_securityhub_organization_configuration" "Org_Config" {
  count = local.IS_SECURITYHUB_ADMIN_ACCOUNT ? 1 : 0

  auto_enable = true
}

#---------------------------------------------------------------------
### SecurityHub Member Accounts

resource "aws_securityhub_member" "Member_Accounts" {
  for_each = (
    local.IS_SECURITYHUB_ADMIN_ACCOUNT
    ? { for k, v in var.securityhub_member_accounts : k => v }
    : {} # The line above resolves ternary-type issue re: var nullability.
  )

  account_id = each.value.id
  email      = each.value.email
  invite     = false

  lifecycle {
    /* This block was added bc TF erroneously keeps wanting to replace
    these resources due to perceived changes in these property values. */
    ignore_changes = [email, invite]
  }
}

#---------------------------------------------------------------------
### SecurityHub Findings Aggregator

/* Each account has their own aggregator. SecurityHub must be enabled
in a region before its aggregator can collect findings from there.  */

resource "aws_securityhub_finding_aggregator" "All_Regions" {
  count = local.IS_SECURITYHUB_ADMIN_ACCOUNT ? 1 : 0

  linking_mode = "ALL_REGIONS"
}

######################################################################
