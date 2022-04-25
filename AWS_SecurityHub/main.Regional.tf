######################################################################
### Regional SecurityHub Resources

locals {
  AVAILABLE_AWS_REGIONS = [
    "ap-northeast-1", # Asia Pacific (Tokyo)
    "ap-northeast-2", # Asia Pacific (Seoul)
    "ap-northeast-3", # Asia Pacific (Osaka)
    "ap-south-1",     # Asia Pacific (Mumbai)
    "ap-southeast-1", # Asia Pacific (Singapore)
    "ap-southeast-2", # Asia Pacific (Sydney)
    "ca-central-1",   # Canada (Central)
    "eu-north-1",     # Europe (Stockholm)
    "eu-central-1",   # Europe (Frankfurt)
    "eu-west-1",      # Europe (Ireland)
    "eu-west-2",      # Europe (London)
    "eu-west-3",      # Europe (Paris)
    "sa-east-1",      # South America (São Paulo)
    "us-east-1",      # US East (N. Virginia)
    "us-east-2",      # US East (Ohio)
    "us-west-1",      # US West (N. California)
    "us-west-2"       # US West (Oregon)
  ]

  standards_arns_by_region = {
    for region in local.AVAILABLE_AWS_REGIONS : region => toset(
      # If user provided values for region, use their list, else set empty list.
      lookup(var.standards_arns_by_region, region, [])
    )
  }
}

/* The resources in this file are structured this way for two reasons:

  1) We know ahead of time that "us-east-2" will always be the
     default provider region within the Fixit project umbrella.
  2) In regard to module design, we're avoiding nested modules in
     favor of a "flat" structure which makes state references
     easier to read, import, etc.
*/

#---------------------------------------------------------------------
### SecurityHub - us-east-2 (HOME REGION USES IMPLICIT/DEFAULT PROVIDER)

resource "aws_securityhub_standards_subscription" "us-east-2" {
  for_each = local.standards_arns_by_region.us-east-2

  standards_arn = each.key
}

#---------------------------------------------------------------------
### SecurityHub - ap-northeast-1

resource "aws_securityhub_account" "ap-northeast-1" {
  provider = aws.ap-northeast-1
}

resource "aws_securityhub_standards_subscription" "ap-northeast-1" {
  for_each = local.standards_arns_by_region.ap-northeast-1
  provider = aws.ap-northeast-1

  standards_arn = each.key
  depends_on    = [aws_securityhub_account.ap-northeast-1]
}

#---------------------------------------------------------------------
### SecurityHub - ap-northeast-2

resource "aws_securityhub_account" "ap-northeast-2" {
  provider = aws.ap-northeast-2
}

resource "aws_securityhub_standards_subscription" "ap-northeast-2" {
  for_each = local.standards_arns_by_region.ap-northeast-2
  provider = aws.ap-northeast-2

  standards_arn = each.key
  depends_on    = [aws_securityhub_account.ap-northeast-2]
}

#---------------------------------------------------------------------
### SecurityHub - ap-northeast-3

resource "aws_securityhub_account" "ap-northeast-3" {
  provider = aws.ap-northeast-3
}

resource "aws_securityhub_standards_subscription" "ap-northeast-3" {
  for_each = local.standards_arns_by_region.ap-northeast-3
  provider = aws.ap-northeast-3

  standards_arn = each.key
  depends_on    = [aws_securityhub_account.ap-northeast-3]
}

#---------------------------------------------------------------------
### SecurityHub - ap-south-1

resource "aws_securityhub_account" "ap-south-1" {
  provider = aws.ap-south-1
}

resource "aws_securityhub_standards_subscription" "ap-south-1" {
  for_each = local.standards_arns_by_region.ap-south-1
  provider = aws.ap-south-1

  standards_arn = each.key
  depends_on    = [aws_securityhub_account.ap-south-1]
}

#---------------------------------------------------------------------
### SecurityHub - ap-southeast-1

resource "aws_securityhub_account" "ap-southeast-1" {
  provider = aws.ap-southeast-1
}

resource "aws_securityhub_standards_subscription" "ap-southeast-1" {
  for_each = local.standards_arns_by_region.ap-southeast-1
  provider = aws.ap-southeast-1

  standards_arn = each.key
  depends_on    = [aws_securityhub_account.ap-southeast-1]
}

#---------------------------------------------------------------------
### SecurityHub - ap-southeast-2

resource "aws_securityhub_account" "ap-southeast-2" {
  provider = aws.ap-southeast-2
}

resource "aws_securityhub_standards_subscription" "ap-southeast-2" {
  for_each = local.standards_arns_by_region.ap-southeast-2
  provider = aws.ap-southeast-2

  standards_arn = each.key
  depends_on    = [aws_securityhub_account.ap-southeast-2]
}

#---------------------------------------------------------------------
### SecurityHub - ca-central-1

resource "aws_securityhub_account" "ca-central-1" {
  provider = aws.ca-central-1
}

resource "aws_securityhub_standards_subscription" "ca-central-1" {
  for_each = local.standards_arns_by_region.ca-central-1
  provider = aws.ca-central-1

  standards_arn = each.key
  depends_on    = [aws_securityhub_account.ca-central-1]
}

#---------------------------------------------------------------------
### SecurityHub - eu-north-1

resource "aws_securityhub_account" "eu-north-1" {
  provider = aws.eu-north-1
}

resource "aws_securityhub_standards_subscription" "eu-north-1" {
  for_each = local.standards_arns_by_region.eu-north-1
  provider = aws.eu-north-1

  standards_arn = each.key
  depends_on    = [aws_securityhub_account.eu-north-1]
}

#---------------------------------------------------------------------
### SecurityHub - eu-central-1

resource "aws_securityhub_account" "eu-central-1" {
  provider = aws.eu-central-1
}

resource "aws_securityhub_standards_subscription" "eu-central-1" {
  for_each = local.standards_arns_by_region.eu-central-1
  provider = aws.eu-central-1

  standards_arn = each.key
  depends_on    = [aws_securityhub_account.eu-central-1]
}

#---------------------------------------------------------------------
### SecurityHub - eu-west-1

resource "aws_securityhub_account" "eu-west-1" {
  provider = aws.eu-west-1
}

resource "aws_securityhub_standards_subscription" "eu-west-1" {
  for_each = local.standards_arns_by_region.eu-west-1
  provider = aws.eu-west-1

  standards_arn = each.key
  depends_on    = [aws_securityhub_account.eu-west-1]
}

#---------------------------------------------------------------------
### SecurityHub - eu-west-2

resource "aws_securityhub_account" "eu-west-2" {
  provider = aws.eu-west-2
}

resource "aws_securityhub_standards_subscription" "eu-west-2" {
  for_each = local.standards_arns_by_region.eu-west-2
  provider = aws.eu-west-2

  standards_arn = each.key
  depends_on    = [aws_securityhub_account.eu-west-2]
}

#---------------------------------------------------------------------
### SecurityHub - eu-west-3

resource "aws_securityhub_account" "eu-west-3" {
  provider = aws.eu-west-3
}

resource "aws_securityhub_standards_subscription" "eu-west-3" {
  for_each = local.standards_arns_by_region.eu-west-3
  provider = aws.eu-west-3

  standards_arn = each.key
  depends_on    = [aws_securityhub_account.eu-west-3]
}

#---------------------------------------------------------------------
### SecurityHub - sa-east-1

resource "aws_securityhub_account" "sa-east-1" {
  provider = aws.sa-east-1
}

resource "aws_securityhub_standards_subscription" "sa-east-1" {
  for_each = local.standards_arns_by_region.sa-east-1
  provider = aws.sa-east-1

  standards_arn = each.key
  depends_on    = [aws_securityhub_account.sa-east-1]
}

#---------------------------------------------------------------------
### SecurityHub - us-east-1

resource "aws_securityhub_account" "us-east-1" {
  provider = aws.us-east-1
}

resource "aws_securityhub_standards_subscription" "us-east-1" {
  for_each = local.standards_arns_by_region.us-east-1
  provider = aws.us-east-1

  standards_arn = each.key
  depends_on    = [aws_securityhub_account.us-east-1]
}

#---------------------------------------------------------------------
### SecurityHub - us-west-1

resource "aws_securityhub_account" "us-west-1" {
  provider = aws.us-west-1
}

resource "aws_securityhub_standards_subscription" "us-west-1" {
  for_each = local.standards_arns_by_region.us-west-1
  provider = aws.us-west-1

  standards_arn = each.key
  depends_on    = [aws_securityhub_account.us-west-1]
}

#---------------------------------------------------------------------
### SecurityHub - us-west-2

resource "aws_securityhub_account" "us-west-2" {
  provider = aws.us-west-2
}

resource "aws_securityhub_standards_subscription" "us-west-2" {
  for_each = local.standards_arns_by_region.us-west-2
  provider = aws.us-west-2

  standards_arn = each.key
  depends_on    = [aws_securityhub_account.us-west-2]
}

######################################################################
