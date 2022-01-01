######################################################################
### SecurityHub

/* The admin can add/rm member accounts, and view/update member findings.
Members must subscribe to standards/controls on their own, however.  */

resource "aws_securityhub_organization_admin_account" "Org_Admin_Account" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  admin_account_id = local.security_account_id
}

resource "aws_securityhub_organization_configuration" "Org_Config" {
  count = local.IS_SECURITY_ACCOUNT ? 1 : 0

  auto_enable = true
}

#---------------------------------------------------------------------
### SecurityHub Member Accounts

locals {
  securityhub_member_accounts = {
    for account_name, account_params in var.accounts : account_name => account_params
    if account_params.id != local.security_account_id
  }
}

resource "aws_securityhub_member" "Member_Accounts" {
  for_each = local.IS_SECURITY_ACCOUNT ? local.securityhub_member_accounts : {}

  account_id = each.id
  email      = each.email
  invite     = false

  /* TFR docs recommend using depends_on with the aws_securityhub_account
  resource(s) here, but our use case would be cross-account, which isn't
  implemented at this time. This opens the possibility of 'apply' errors
  if the Security-account tries to add a new SecurityHub member account
  via this block before said account activates SecurityHub via its own
  aws_securityhub_account resource blocks (1/region). To address this
  problem, we need a 'dependency' block in the FCL repo.  */
}

#---------------------------------------------------------------------
### SecurityHub Findings Aggregator

/* Each account has their own aggregator. SecurityHub must be enabled
in a region before its aggregator can collect findings from there.  */

resource "aws_securityhub_finding_aggregator" "All_Regions" {
  linking_mode = "ALL_REGIONS"

  depends_on = [aws_securityhub_account.us-east-2]
}

#---------------------------------------------------------------------
### SecurityHub Standards

/* This local contains the ARNs for the 3 standards we need to enable -
    1) CIS Benchmarks
    2) AWS Foundational Security Best Practices Standard
    3) PCI DSS Standard    # TODO not sure if we need this one
*/

locals {
  STANDARDS_ARNS_BY_REGION = {
    for region in local.all_regions : region => {
      CIS_BENCHMARKS   = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"
      AWS_FOUNDATIONAL = "arn:aws:securityhub:${region}::standards/aws-foundational-security-best-practices/v/1.0.0"
      PCI_DSS          = "arn:aws:securityhub:${region}::standards/pci-dss/v/3.2.1"
    }
  }
}

######################################################################
### REGION-SPECIFIC SECURITY HUB RESOURCES
#---------------------------------------------------------------------
### SecurityHub - us-east-2 (HOME REGION USES IMPLICIT/DEFAULT PROVIDER)

resource "aws_securityhub_account" "us-east-2" {}

resource "aws_securityhub_standards_subscription" "us-east-2" {
  for_each = local.STANDARDS_ARNS_BY_REGION.us-east-2

  standards_arn = each.value
  depends_on    = [aws_securityhub_account.us-east-2]
}

#---------------------------------------------------------------------
### SecurityHub - ap-northeast-1

resource "aws_securityhub_account" "ap-northeast-1" {
  provider = aws.ap-northeast-1
}

resource "aws_securityhub_standards_subscription" "ap-northeast-1" {
  for_each = local.STANDARDS_ARNS_BY_REGION.ap-northeast-1
  provider = aws.ap-northeast-1

  standards_arn = each.value
  depends_on    = [aws_securityhub_account.ap-northeast-1]
}

#---------------------------------------------------------------------
### SecurityHub - ap-northeast-2

resource "aws_securityhub_account" "ap-northeast-2" {
  provider = aws.ap-northeast-2
}

resource "aws_securityhub_standards_subscription" "ap-northeast-2" {
  for_each = local.STANDARDS_ARNS_BY_REGION.ap-northeast-2
  provider = aws.ap-northeast-2

  standards_arn = each.value
  depends_on    = [aws_securityhub_account.ap-northeast-2]
}

#---------------------------------------------------------------------
### SecurityHub - ap-northeast-3

resource "aws_securityhub_account" "ap-northeast-3" {
  provider = aws.ap-northeast-3
}

resource "aws_securityhub_standards_subscription" "ap-northeast-3" {
  for_each = local.STANDARDS_ARNS_BY_REGION.ap-northeast-3
  provider = aws.ap-northeast-3

  standards_arn = each.value
  depends_on    = [aws_securityhub_account.ap-northeast-3]
}

#---------------------------------------------------------------------
### SecurityHub - ap-south-1

resource "aws_securityhub_account" "ap-south-1" {
  provider = aws.ap-south-1
}

resource "aws_securityhub_standards_subscription" "ap-south-1" {
  for_each = local.STANDARDS_ARNS_BY_REGION.ap-south-1
  provider = aws.ap-south-1

  standards_arn = each.value
  depends_on    = [aws_securityhub_account.ap-south-1]
}

#---------------------------------------------------------------------
### SecurityHub - ap-southeast-1

resource "aws_securityhub_account" "ap-southeast-1" {
  provider = aws.ap-southeast-1
}

resource "aws_securityhub_standards_subscription" "ap-southeast-1" {
  for_each = local.STANDARDS_ARNS_BY_REGION.ap-southeast-1
  provider = aws.ap-southeast-1

  standards_arn = each.value
  depends_on    = [aws_securityhub_account.ap-southeast-1]
}

#---------------------------------------------------------------------
### SecurityHub - ap-southeast-2

resource "aws_securityhub_account" "ap-southeast-2" {
  provider = aws.ap-southeast-2
}

resource "aws_securityhub_standards_subscription" "ap-southeast-2" {
  for_each = local.STANDARDS_ARNS_BY_REGION.ap-southeast-2
  provider = aws.ap-southeast-2

  standards_arn = each.value
  depends_on    = [aws_securityhub_account.ap-southeast-2]
}

#---------------------------------------------------------------------
### SecurityHub - ca-central-1

resource "aws_securityhub_account" "ca-central-1" {
  provider = aws.ca-central-1
}

resource "aws_securityhub_standards_subscription" "ca-central-1" {
  for_each = local.STANDARDS_ARNS_BY_REGION.ca-central-1
  provider = aws.ca-central-1

  standards_arn = each.value
  depends_on    = [aws_securityhub_account.ca-central-1]
}

#---------------------------------------------------------------------
### SecurityHub - eu-north-1

resource "aws_securityhub_account" "eu-north-1" {
  provider = aws.eu-north-1
}

resource "aws_securityhub_standards_subscription" "eu-north-1" {
  for_each = local.STANDARDS_ARNS_BY_REGION.eu-north-1
  provider = aws.eu-north-1

  standards_arn = each.value
  depends_on    = [aws_securityhub_account.eu-north-1]
}

#---------------------------------------------------------------------
### SecurityHub - eu-central-1

resource "aws_securityhub_account" "eu-central-1" {
  provider = aws.eu-central-1
}

resource "aws_securityhub_standards_subscription" "eu-central-1" {
  for_each = local.STANDARDS_ARNS_BY_REGION.eu-central-1
  provider = aws.eu-central-1

  standards_arn = each.value
  depends_on    = [aws_securityhub_account.eu-central-1]
}

#---------------------------------------------------------------------
### SecurityHub - eu-west-1

resource "aws_securityhub_account" "eu-west-1" {
  provider = aws.eu-west-1
}

resource "aws_securityhub_standards_subscription" "eu-west-1" {
  for_each = local.STANDARDS_ARNS_BY_REGION.eu-west-1
  provider = aws.eu-west-1

  standards_arn = each.value
  depends_on    = [aws_securityhub_account.eu-west-1]
}

#---------------------------------------------------------------------
### SecurityHub - eu-west-2

resource "aws_securityhub_account" "eu-west-2" {
  provider = aws.eu-west-2
}

resource "aws_securityhub_standards_subscription" "eu-west-2" {
  for_each = local.STANDARDS_ARNS_BY_REGION.eu-west-2
  provider = aws.eu-west-2

  standards_arn = each.value
  depends_on    = [aws_securityhub_account.eu-west-2]
}

#---------------------------------------------------------------------
### SecurityHub - eu-west-3

resource "aws_securityhub_account" "eu-west-3" {
  provider = aws.eu-west-3
}

resource "aws_securityhub_standards_subscription" "eu-west-3" {
  for_each = local.STANDARDS_ARNS_BY_REGION.eu-west-3
  provider = aws.eu-west-3

  standards_arn = each.value
  depends_on    = [aws_securityhub_account.eu-west-3]
}

#---------------------------------------------------------------------
### SecurityHub - sa-east-1

resource "aws_securityhub_account" "sa-east-1" {
  provider = aws.sa-east-1
}

resource "aws_securityhub_standards_subscription" "sa-east-1" {
  for_each = local.STANDARDS_ARNS_BY_REGION.sa-east-1
  provider = aws.sa-east-1

  standards_arn = each.value
  depends_on    = [aws_securityhub_account.sa-east-1]
}

#---------------------------------------------------------------------
### SecurityHub - us-east-1

resource "aws_securityhub_account" "us-east-1" {
  provider = aws.us-east-1
}

resource "aws_securityhub_standards_subscription" "us-east-1" {
  for_each = local.STANDARDS_ARNS_BY_REGION.us-east-1
  provider = aws.us-east-1

  standards_arn = each.value
  depends_on    = [aws_securityhub_account.us-east-1]
}

#---------------------------------------------------------------------
### SecurityHub - us-west-1

resource "aws_securityhub_account" "us-west-1" {
  provider = aws.us-west-1
}

resource "aws_securityhub_standards_subscription" "us-west-1" {
  for_each = local.STANDARDS_ARNS_BY_REGION.us-west-1
  provider = aws.us-west-1

  standards_arn = each.value
  depends_on    = [aws_securityhub_account.us-west-1]
}

#---------------------------------------------------------------------
### SecurityHub - us-west-2

resource "aws_securityhub_account" "us-west-2" {
  provider = aws.us-west-2
}

resource "aws_securityhub_standards_subscription" "us-west-2" {
  for_each = local.STANDARDS_ARNS_BY_REGION.us-west-2
  provider = aws.us-west-2

  standards_arn = each.value
  depends_on    = [aws_securityhub_account.us-west-2]
}

######################################################################
