######################################################################
### Terraform Version Info

terraform {
  required_version = "1.2.6"
  experiments      = [module_variable_optional_attrs]

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.11.0"
    }
  }
}

######################################################################
