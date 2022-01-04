######################################################################
### Terraform Version Info

terraform {
  required_version = ">= 1.0.0"
  experiments      = [module_variable_optional_attrs]

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0.0"
    }
  }
}

######################################################################
