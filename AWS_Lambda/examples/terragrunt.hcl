######################################################################
### EXAMPLE USAGE: AWS_Lambda

/* As in any Terragrunt configuration, the inputs below can be
provided in a single standalone resource config, or may be broken up
across multiple resource configs and utilized with a combination of
include-blocks and/or the read_terragrunt_config() Terragrunt fn. */

#---------------------------------------------------------------------
### Dependencies

dependency "ECR" {
  config_path = "${get_terragrunt_dir()}/../Foo_ECR_Repo"
}

dependency "IAM" {
  config_path = "${get_terragrunt_dir()}/../AWS_IAM"
}

dependency "VPC" {
  config_path = "${get_terragrunt_dir()}/../Foo_VPC"
}

dependency "EventBridge" {
  config_path = "${get_terragrunt_dir()}/../Foo_EventBridge"
}

#---------------------------------------------------------------------
### Inputs

inputs = {

  name    = "my-lambda-function"
  handler = "index.handler"
  runtime = "nodejs16.x"
  deployment_package_src = {
    image_uri = "${dependency.ECR.outputs.Repositories["Foo_ECR_Repo"].repository_url}:my-lambda-function_v1"
    # URI Format: [ACCOUNT_ID].dkr.ecr.[REGION].amazonaws.com/[REPO_NAME]:[TAG]
  }

  execution_role_arn = dependency.IAM.outputs.Roles["MyLambdaFnExecRole"].arn

  vpc_config = {
    security_group_ids = [
      for sec_grp_name, sec_grp in dependency.VPC.outputs.Security_Groups : sec_grp.id
      if sec_grp_name == "my-lambda-fn-security-group"
    ]
    subnet_ids = [
      for cidr, subnet in dependency.VPC.outputs.Subnets : subnet.id
      if subnet.type == "PRIVATE"
    ]
  }

  environment_variables = {
    AWS_REGION = "us-west-1"
  }

  lambda_permissions = {
    "events.amazonaws.com" = {
      action       = "lambda:InvokeFunction"
      statement_id = "AllowEventBridgeInvocation"
      source_arn   = dependency.EventBridge.outputs.Event_Rules["run-every-30-mins"].arn
    }
  }
}

######################################################################
