######################################################################
### EXAMPLE USAGE: AWS_KMS

/* As in any Terragrunt configuration, the inputs below can be
provided in a single standalone resource config, or may be broken up
across multiple resource configs and utilized with a combination of
include-blocks and/or the read_terragrunt_config() Terragrunt fn. */

#---------------------------------------------------------------------
### Dependencies

dependency "AWS_Org" {
  config_path = "../../root/AWS_Organization"
}

#---------------------------------------------------------------------
### Inputs

inputs = {
  key_alias                  = "My_KMS_Key"
  is_multi_region_key        = true
  should_enable_key_rotation = true

  key_policy = jsonencode({
    Version = "2012-10-17"
    Statement = {
      Sid       = "EnableOrgPrincipalsUsage"
      Effect    = "Allow"
      Principal = { AWS = dependency.AWS_Org.outputs.Organization.accounts[*].arn }
      Action    = "kms:*"
      Resource  = "*"
      Condition = {
        StringEquals = {
          "aws:PrincipalOrgID" = dependency.AWS_Org.outputs.Organization.id
        }
      }
    }
  })

  regional_replicas = {
    ap-northeast-1 = true # Asia Pacific (Tokyo)
    ap-northeast-2 = true # Asia Pacific (Seoul)
    ap-northeast-3 = true # Asia Pacific (Osaka)
    ap-south-1     = true # Asia Pacific (Mumbai)
    ap-southeast-1 = true # Asia Pacific (Singapore)
    ap-southeast-2 = true # Asia Pacific (Sydney)
    ca-central-1   = true # Canada (Central)
    eu-north-1     = true # Europe (Stockholm)
    eu-central-1   = true # Europe (Frankfurt)
    eu-west-1      = true # Europe (Ireland)
    eu-west-2      = true # Europe (London)
    eu-west-3      = true # Europe (Paris)
    sa-east-1      = true # South America (São Paulo)
    us-east-1      = true # US East (N. Virginia)
    us-west-1      = true # US West (N. California)
    us-west-2      = true # US West (Oregon)
  }
}

######################################################################
