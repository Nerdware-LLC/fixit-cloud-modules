######################################################################
### EXAMPLE USAGE: AWS_ECR

/* As in any Terragrunt configuration, the inputs below can be
provided in a single standalone resource config, or may be broken up
across multiple resource configs and utilized with a combination of
include-blocks and/or the read_terragrunt_config() Terragrunt fn. */

#---------------------------------------------------------------------
### Dependencies

dependency "Org" {
  config_path = "${get_terragrunt_dir()}/../AWS_Organization"
}

#---------------------------------------------------------------------
### Inputs

locals {
  ORG_SHARED_REPO_NAME = "My_Orgs_Shared_ECR_Repo"
}

inputs = {

  repositories = {
    "${local.ORG_SHARED_REPO_NAME}" = {

      tags = { Name = local.ORG_SHARED_REPO_NAME }

      policy_config = {
        allow_push_and_pull_images = {
          principals = {
            type = "AWS"
            identifiers = [
              for account in dependency.Org.outputs.Organization.accounts : "arn:aws:iam:${account.id}:root"
              if contains(["My_Dev_Account", "My_Prod_Account"], account.name)
            ]
          }
          conditions = {
            "ForAnyValue:StringLike" = {
              key = "aws:PrincipalOrgPaths"
              values = [
                "${dependency.Org.outputs.Organization.id}/*/${dependency.Org.outputs.Organizational_Units["Workloads_OU"].id}"
              ]
            }
          }
        }
      }
    }
  }

  registry_scanning_config = {
    scan_type = "BASIC"
  }
}

######################################################################
