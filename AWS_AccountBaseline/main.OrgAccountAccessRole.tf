######################################################################
### OrganizationAccountAccessRole

/* The role "OrganizationAccountAccessRole" provides Admin-level access
to an account's resources; it therefore must be locked down.  */

# TODO replace IAM user in below policy with "Administrators" SSO group. NOTE: IP addresses not used.

resource "aws_iam_role" "OrganizationAccountAccessRole" {
  name        = "OrganizationAccountAccessRole"
  description = "A role used by Administrators to manage AWS resources in Terraform/Terragrunt configs."
  path        = "/"
  tags        = { Name = "OrganizationAccountAccessRole" }

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = [
          for admin_iam_username in var.administrators :
          "arn:aws:iam::${local.root_account_id}:user/${admin_iam_username}"
        ]
      }
      Action = "sts:AssumeRole"
    }]
  })
}

######################################################################
