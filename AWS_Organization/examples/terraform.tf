######################################################################
### EXAMPLE USAGE: AWS_Organization

module "AWS_Organization" {
  source = "git@github.com:Nerdware-LLC/fixit-cloud-modules.git//AWS_Organization"

  organization_config = {
    org_trusted_services = [
      "access-analyzer.amazonaws.com",
      "cloudtrail.amazonaws.com",
      "config.amazonaws.com",
      "guardduty.amazonaws.com",
      "inspector2.amazonaws.com",
      "securityhub.amazonaws.com",
      "sso.amazonaws.com",
      "tagpolicies.tag.amazonaws.com"
    ]
    enabled_policy_types = [
      "AISERVICES_OPT_OUT_POLICY",
      "BACKUP_POLICY",
      "SERVICE_CONTROL_POLICY",
      "TAG_POLICY"
    ]
  }

  organizational_units = {
    Core_OU           = { parent = "root" }
    Workloads_OU      = { parent = "root" }
    Dev_Workloads_OU  = { parent = "Workloads_OU" }
    Prod_Workloads_OU = { parent = "Workloads_OU" }
  }

  member_accounts = {
    LogArchive = {
      parent = "Core_OU"
      email  = "my_aws_account_email+LOG_ARCHIVE@gmail.com"
      /* EMAIL TIP: if you don't actually want separate
      email addresses for your accounts, for most email
      providers you can create "alternate" email addresses
      which route to the same inbox using the "+" format
      shown above. In this example, the root AWS account
      email would be "my_aws_account_email@gmail.com", and
      any email correspondance sent to either email address
      will be routed to the same inbox - without having to
      configure any forwarding.  */
    }
    Security = {
      parent = "Core_OU"
      email  = "foo_org_security@foo.com"
    }
    SharedServices = {
      parent = "Core_OU"
      email  = "my_aws_account_email+SHARED_SERVICES@gmail.com"
    }
    Development = {
      parent = "Dev_Workloads_OU"
      email  = "1337_devs@foo.com"
    }
    Production = {
      parent = "Prod_Workloads_OU"
      email  = "1337_devs+PROD_ALERTS@foo.com"
    }
  }

  delegated_administrators = {
    "guardduty.amazonaws.com"   = "Security"
    "securityhub.amazonaws.com" = "Security"
    "inspector2.amazonaws.com"  = "Security"
  }

  organization_policies = {
    Restrict_Instance_Types = {
      target      = "root"
      type        = "SERVICE_CONTROL_POLICY"
      description = "A deny policy that sets requirements for EC2 properties."
      statement = jsonencode({
        Version = "2012-10-17"
        Statement = {
          Effect   = "Deny"
          Action   = "ec2:RunInstances"
          Resource = ["arn:aws:ec2:*:*:instance/*"]
          Condition = {
            "ForAnyValue:StringNotEquals" = {
              "ec2:InstanceType" = ["t3.micro", "t3a.micro"]
            }
          }
        }
      })
    }
    All_Org_AI_Svcs_Opt_Out_Policy = {
      target      = "root"
      type        = "AISERVICES_OPT_OUT_POLICY"
      description = "An AI Services Opt Out Policy that applies to the entire organization with no allowed overrides."
      statement = jsonencode({
        services = {
          "@@operators_allowed_for_child_policies" = ["@@none"]
          default = {
            "@@operators_allowed_for_child_policies" = ["@@none"]
            opt_out_policy = {
              "@@operators_allowed_for_child_policies" = ["@@none"]
              "@@assign"                               = "optOut"
            }
          }
        }
      })
    }
  }

  admin_sso_config = {
    sso_group_name             = "My_SSO_Admins"
    permission_set_name        = "AdministratorAccess"
    permission_set_description = "Admin access to organization accounts and resources."
  }

  org_access_analyzer = {
    name = "My_Org_Access_Analyzer"
  }
}

######################################################################
