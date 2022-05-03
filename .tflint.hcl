######################################################################
### TFLint Config

# Docs => https://github.com/terraform-linters/tflint/blob/master/docs

config {
  plugin_dir = "~/.tflint.d/plugins"
  module     = true
}

#---------------------------------------------------------------------
### TFLint Plugins

plugin "aws" {
  enabled = true
  version = "0.13.3"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

#---------------------------------------------------------------------
### TFLint Rules

# Require comments be started with "#", not "//"
rule "terraform_comment_syntax" {
  enabled = true
}

# Disallow legacy dot index syntax
rule "terraform_deprecated_index" {
  enabled = true
}

# Require output descriptions
rule "terraform_documented_outputs" {
  enabled = true
}

# Require variable descriptions
rule "terraform_documented_variables" {
  enabled = true
}

# Disallow terraform declarations without required_version
rule "terraform_required_version" {
  enabled = true
}

# Require TF standard module structure
rule "terraform_standard_module_structure" {
  enabled = true
}

# Require that all providers have version constraints
rule "terraform_required_providers" {
  enabled = true
}

# Disallow variables that don't specify a "type"
rule "terraform_typed_variables" {
  enabled = true
}

# Disallow vars that are declared but never used
rule "terraform_unused_declarations" {
  enabled = true
}

# Disallow required_providers that are declared but never used
rule "terraform_unused_required_providers" {
  enabled = true
}

######################################################################
