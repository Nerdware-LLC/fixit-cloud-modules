######################################################################
### EXAMPLE USAGE: AWS_IAM

module "AWS_Org" {
  /* dependency module inputs */
}

module "Log_Archive_Bucket" {
  /* dependency module inputs */
}

module "ECR_Repo" {
  /* dependency module inputs */
}

#---------------------------------------------------------------------

module "AWS_IAM" {
  source = "git@github.com:Nerdware-LLC/fixit-cloud-modules.git//AWS_IAM"

  # OpenID Connect Identity Providers --------------------------------

  openID_connect_providers = {
    GitHub = {
      url             = "https://token.actions.githubusercontent.com"
      client_id_list  = ["sts.amazonaws.com"]
      thumbprint_list = ["6938FD4D98BAB03FAADB97B34396831E3780AEA1"]
      tags            = { Name = "GitHub_OpenID_Connect_Provider" }
    }
  }

  # ROLES ------------------------------------------------------------

  iam_roles = {

    FooAdminRole = {
      description = "A role used by FooAdmin."
      assume_role_policy_statements = [{
        effect = "Allow"
        principals = {
          AWS = ["arn:aws:iam::${module.AWS_Org.Organization.master_account_id}:user/FooAdmin"]
        }
        actions = ["sts:AssumeRole"]
      }]
    }

    GitHub_OIDC_IdP_Role = {
      description     = "IAM Role for the GitHub OpenID-Connect Identity Provider."
      attach_policies = ["AllowGitHubActionsOIDCtoPushECRimages"]
      assume_role_policy_statements = [{
        effect                        = "Allow"
        principals                    = { Federated = ["GitHub"] }
        should_lookup_oidc_principals = true
        actions                       = ["sts:AssumeRoleWithWebIdentity"]
        conditions = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud"              = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:repository_owner" = "FooGitHubAccountName"
            "token.actions.githubusercontent.com:sub" = [
              "repo:FooGitHubAccountName/my-repo-github-oidc-will-access:*",
              "repo:FooGitHubAccountName/foo-lambda-function-repo:*"
              /*
                Regarding GitHub OIDC "sub" claims, additional filters can be
                appended to the repo name which will be tested against the OIDC
                token's "sub" claim. Repo filters take this shape:

                  repo:octo-org/octo-repo:ref:refs/heads/demo-branch

                More info on these filters can be found via the link below.
                https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#example-subject-claims
              */
            ]
          }
        }
      }]
    }

    Org_Config_Role = {
      description     = "An IAM service role for the AWS-Config service."
      attach_policies = ["Org_Config_Role_Policy"]
      assume_role_policy_statements = [{
        effect     = "Allow"
        principals = { Service = ["config.amazonaws.com"] }
        actions    = ["sts:AssumeRole"]
      }]
    }
  }

  # SERVICE-LINKED ROLES ---------------------------------------------

  iam_service_linked_roles = {
    "cloudwatch-crossaccount.amazonaws.com" = {
      description = "Used by CloudWatch in monitoring accounts to display cross-account and cross-region CloudWatch data."
      tags        = { Service = "cloudwatch-crossaccount.amazonaws.com" }
    }
  }

  # POLICIES ---------------------------------------------------------

  iam_policies = {

    Allow_GitHub-Actions_OIDC_to_push_images_to_ECR = {
      statements = [
        {
          effect = "Allow"
          actions = [
            "ecr:BatchGetImage",
            "ecr:BatchCheckLayerAvailability",
            "ecr:CompleteLayerUpload",
            "ecr:GetDownloadUrlForLayer",
            "ecr:InitiateLayerUpload",
            "ecr:PutImage",
            "ecr:UploadLayerPart",
          ]
          resources = [module.ECR_Repo.Repository.arn]
        },
        {
          effect    = "Allow"
          actions   = ["ecr:GetAuthorizationToken"]
          resources = ["*"]
        }
      ]
    }

    Org_Config_Role_Policy = {
      description = "Permits Config service access to Log-Archive S3 bucket and KMS Key."
      statements = [
        {
          effect    = "Allow"
          actions   = ["s3:GetBucketAcl"]
          resources = [module.Log_Archive_Bucket.Bucket.arn]
        },
        {
          effect = "Allow"
          actions = [
            "s3:PutObject",
            "s3:PutObjectAcl"
          ]
          resources = ["${module.Log_Archive_Bucket.Bucket.arn}/*"]
          conditions = {
            StringLike = {
              key    = "s3:x-amz-acl"
              values = ["bucket-owner-full-control"]
            }
          }
        },
        {
          effect    = "Allow"
          actions   = ["kms:Decrypt", "kms:GenerateDataKey"]
          resources = [module.Log_Archive_Bucket.Bucket_SSE_KMS_Key.arn]
        }
      ]
    }
  }
}

######################################################################
