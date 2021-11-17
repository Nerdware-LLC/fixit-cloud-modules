###################################################
### Terraform Version Info

terraform {
  required_version = ">= 1.0.0"
  experiments      = [module_variable_optional_attrs]

  required_providers {
    tfe = {
      version = "~> 0.26.0"
    }
  }
}

###################################################
