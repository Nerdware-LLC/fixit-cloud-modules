######################################################################
### Terraform Version Info

terraform {
  required_version = "1.3.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.34.0"

      /* This module creates AWS resources which must be created in
      all available AWS regions, thereby necessitating provider
      aliases be provided for all available regions except the region
      set in the default/non-aliased provider, which for this project
      is always "us-east-2".  */
      configuration_aliases = [
        aws.ap-northeast-1, # Asia Pacific (Tokyo)
        aws.ap-northeast-2, # Asia Pacific (Seoul)
        aws.ap-northeast-3, # Asia Pacific (Osaka)
        aws.ap-south-1,     # Asia Pacific (Mumbai)
        aws.ap-southeast-1, # Asia Pacific (Singapore)
        aws.ap-southeast-2, # Asia Pacific (Sydney)
        aws.ca-central-1,   # Canada (Central)
        aws.eu-north-1,     # Europe (Stockholm)
        aws.eu-central-1,   # Europe (Frankfurt)
        aws.eu-west-1,      # Europe (Ireland)
        aws.eu-west-2,      # Europe (London)
        aws.eu-west-3,      # Europe (Paris)
        aws.sa-east-1,      # South America (São Paulo)
        aws.us-east-1,      # US East (N. Virginia)
        aws.us-west-1,      # US West (N. California)
        aws.us-west-2       # US West (Oregon)
      ]
    }
  }
}

######################################################################
