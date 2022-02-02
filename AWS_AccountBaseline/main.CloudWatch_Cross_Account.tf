######################################################################
### CloudWatch: Cross-Account & Cross-Region Data/Dashboards

# Docs: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Cross-Account-Cross-Region.html

/* As of 1/2/22, the two IAM role resources listed below show a constant erroneous
diff on the Principal list element of their respective assume_role_policy values.
- CloudWatch-CrossAccountSharingRole                (Principals are accounts that SHARE CloudWatch data)
- CloudWatch-CrossAccountSharing-ListAccountsRole   (Principals are accounts that MONITOR CloudWatch data shared by sharing accounts)

The problem is caused by the fact that AWS does not maintain the same order in the
Principals list that the user submits, even when submitted via the console. We don't
want to put assume_role_policy in ignore_changes, so until a fix can be found we'll
just have to ignore the "hey this stuff changed" msg during Terragrunt plans/applies. */

locals {
  cloudwatch_SHARING_account_arns = [
    for account in values(var.accounts) : "arn:aws:iam::${account.id}:root"
    if lookup(account, "should_enable_cross_account_cloudwatch_sharing", false) == true
  ]

  cloudwatch_MONITORING_account_arns = [
    for account in values(var.accounts) : "arn:aws:iam::${account.id}:root"
    if lookup(account, "should_enable_cross_account_cloudwatch_monitoring", false) == true
  ]
}

#---------------------------------------------------------------------
### SHARING ROLE: CloudWatch-CrossAccountSharingRole

resource "aws_iam_role" "CloudWatch-CrossAccountSharingRole" {
  count = local.caller_account_configs.should_enable_cross_account_cloudwatch_sharing == true ? 1 : 0

  name        = "CloudWatch-CrossAccountSharingRole"
  description = "Allows one or more CloudWatch monitoring accounts to view CloudWatch data from this account."
  tags        = { Name = "CloudWatch-CrossAccountSharingRole" }

  /* If more cross-account access functionality is desired, we can put together
  a custom policy based on "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess",
  which AWS docs describes as follows, "This option enables the accounts that
  you use for sharing to create cross-account dashboards that include widgets
  that contain CloudWatch data from your account. It also enables those accounts
  to look deeper into your account and view your account's data in the consoles
  of other AWS services.". This managed policy was excluded from the below list
  due to security concerns regarding the large number of actions it permits.  */
  managed_policy_arns = sort([
    "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess",
    "arn:aws:iam::aws:policy/CloudWatchAutomaticDashboardsAccess",
    "arn:aws:iam::aws:policy/AWSXrayReadOnlyAccess"
  ])

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = local.cloudwatch_SHARING_account_arns
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "aws:PrincipalOrgID" = local.org_id
          }
        }
      }
    ]
  })
}

#---------------------------------------------------------------------
### MONITORING ROLE: AWSServiceRoleForCloudWatchCrossAccount

resource "aws_iam_service_linked_role" "AWSServiceRoleForCloudWatchCrossAccount" {
  count = local.caller_account_configs.should_enable_cross_account_cloudwatch_monitoring == true ? 1 : 0

  aws_service_name = "cloudwatch-crossaccount.amazonaws.com"
  description      = "Used by CloudWatch in monitoring accounts to display cross-account and cross-region CloudWatch data."
}

#---------------------------------------------------------------------
### ROLES to provide EC2 CloudWatch-Agents with Cross-Account Access

resource "aws_iam_role" "CloudWatch_Agent_Server_Role_RECEIVER" {
  count = local.IS_LOG_ARCHIVE_ACCOUNT == true ? 1 : 0

  name                = "CloudWatch_Agent_Server_Role"
  description         = "Allows EC2 CloudWatch-Agents in other Org accounts to send logs and metrics to this account."
  managed_policy_arns = ["arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"]
  tags                = { Name = "CloudWatch_Agent_Server_Role_RECEIVER" }

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = [for account_id in local.all_account_ids : "arn:aws:iam::${account_id}:role/CloudWatch_Agent_Server_Role"]
      }
      Action = "sts:AssumeRole"
      Condition = {
        StringEquals = {
          "aws:PrincipalOrgID" = local.org_id
        }
      }
    }]
  })
}

resource "aws_iam_role" "CloudWatch_Agent_Server_Role" {
  count = local.IS_LOG_ARCHIVE_ACCOUNT == true ? 1 : 0

  name        = "CloudWatch_Agent_Server_Role"
  description = "Allows EC2 CloudWatch-Agents in this account to send logs and metrics to the Log-Archive account."
  tags        = { Name = "CloudWatch_Agent_Server_Role" }

  assume_role_policy = jsonencode() # FIXME
}

resource "aws_iam_policy" "CloudWatch_Agent_Server_Role_Policy" {
  count = local.IS_LOG_ARCHIVE_ACCOUNT == false ? 1 : 0

  name        = "CloudWatch_Agent_Server_Role_Policy"
  description = "Allows EC2 CloudWatch-Agents in this account to send logs and metrics to the Log-Archive account."
  path        = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "sts:AssumeRole"
      Resource = "arn:aws:iam::${local.log_archive_account_id}:role/CloudWatch_Agent_Server_Role_RECEIVER"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "CloudWatch_Agent_Server_Role-PolicyAttachments" {
  for_each = toset(
    local.IS_LOG_ARCHIVE_ACCOUNT == false
    ? ["arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy", one(aws_iam_policy.CloudWatch_Agent_Server_Role_Policy).arn]
    : []
  )

  role       = one(aws_iam_role.CloudWatch_Agent_Server_Role).name
  policy_arn = each.key
}

#---------------------------------------------------------------------
### CloudWatch-CrossAccountSharing-ListAccountsRole

/* This role enables the account to view a dropdown list of all sharing-accounts in
CloudWatch which can be used to switch between various accounts data/dashboards. */

resource "aws_iam_role" "CloudWatch-CrossAccountSharing-ListAccountsRole" {
  count = local.caller_account_configs.should_enable_cross_account_cloudwatch_monitoring == true ? 1 : 0

  name        = "CloudWatch-CrossAccountSharing-ListAccountsRole"
  description = "Allows one or more CloudWatch-monitoring accounts to view a list of Org accounts."
  tags        = { Name = "CloudWatch-CrossAccountSharing-ListAccountsRole" }

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = local.cloudwatch_MONITORING_account_arns
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "aws:PrincipalOrgID" = local.org_id
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "CloudWatch-CrossAccountSharing-ListAccounts-Policy" {
  count = local.caller_account_configs.should_enable_cross_account_cloudwatch_monitoring == true ? 1 : 0

  name        = "CloudWatch-CrossAccountSharing-ListAccounts-Policy"
  description = "Allows one or more CloudWatch-monitoring accounts to view a list of Org accounts."
  path        = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "organizations:ListAccounts"
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = "organizations:ListAccountsForParent"
        Resource = "arn:aws:organizations::${local.root_account_id}:root/${local.org_id}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "CloudWatch-CrossAccountSharing-ListAccounts-Policy" {
  count = local.caller_account_configs.should_enable_cross_account_cloudwatch_monitoring == true ? 1 : 0

  role       = one(aws_iam_role.CloudWatch-CrossAccountSharing-ListAccountsRole).name
  policy_arn = one(aws_iam_policy.CloudWatch-CrossAccountSharing-ListAccounts-Policy).arn
}

######################################################################
