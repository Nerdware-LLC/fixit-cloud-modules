######################################################################
### EXAMPLE USAGE: AWS_ECR

module "Org_Module" {
  /* Org module inputs */
}

module "AWS_ECR" {
  source = "git@github.com:Nerdware-LLC/fixit-cloud-modules.git//AWS_ECR"

  repositories = {
    "${local.ORG_SHARED_REPO_NAME}" = {

      tags = { Name = local.ORG_SHARED_REPO_NAME }

      policy_config = {
        allow_push_and_pull_images = {
          principals = {
            type = "AWS"
            identifiers = [
              for account in module.Org_Module.Organization.accounts : "arn:aws:iam:${account.id}:root"
              if contains(["My_Dev_Account", "My_Prod_Account"], account.name)
            ]
          }
          conditions = {
            "ForAnyValue:StringLike" = {
              key = "aws:PrincipalOrgPaths"
              values = [
                "${module.Org_Module.Organization.id}/*/${module.Org_Module.Organizational_Units["Workloads_OU"].id}"
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
