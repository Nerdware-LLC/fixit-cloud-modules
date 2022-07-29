######################################################################
### Terraform Version Info

terraform {
  required_version = "1.2.6"
  experiments      = [module_variable_optional_attrs]

  required_providers {
    tfe = {
      version = "~> 0.28.1"
    }
  }
}

######################################################################
