##################################################
### TFLint Config

# Docs => https://github.com/terraform-linters/tflint/blob/master/docs

config {
  plugin_dir = "./.tflint.d/plugins"
  module     = true
}

plugin "aws" {
  enabled = true
  version = "0.9.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

##################################################
