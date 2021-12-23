######################################################################
### TFLint Config

# Docs => https://github.com/terraform-linters/tflint/blob/master/docs

config {
  plugin_dir = "~/.tflint.d/plugins"
  module     = true
}

plugin "aws" {
  enabled = true
  version = "0.9.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# Disallow legacy dot index syntax
rule "terraform_deprecated_index" {
  enabled = true
}

# Require comments be started with "#", not "//"
rule "terraform_comment_syntax" {
  enabled = true
}

# Disallow terraform declarations without required_version
rule "terraform_required_version" {
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
