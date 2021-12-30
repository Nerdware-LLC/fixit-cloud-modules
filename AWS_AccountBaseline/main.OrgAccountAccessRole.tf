######################################################################
### OrganizationAccountAccessRole

/* The role "OrganizationAccountAccessRole" provides Admin-level access
to an account's resources; it therefore must be locked down.  */

resource "aws_iam_role" "OrganizationAccountAccessRole" {
  name        = "OrganizationAccountAccessRole"
  description = "A role used by Administrators to manage AWS resources in Terraform/Terragrunt configs."
  path        = "/"
  tags        = { Name = "OrganizationAccountAccessRole" }

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${local.root_account_id}:root" }
        Action    = "sts:AssumeRole"
        Condition = {
          IpAddress = { "aws:SourceIp" = var.administrator_ip_addresses }
        }
      }
    ]
  })
}

######################################################################
