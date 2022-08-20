######################################################################
### EXAMPLE USAGE: AWS_Lambda
######################################################################

module "ECR" {
  /* dependency inputs */
}

module "IAM" {
  /* dependency inputs */
}

module "VPC" {
  /* dependency inputs */
}

module "EventBridge" {
  /* dependency inputs */
}

#---------------------------------------------------------------------

module "AWS_Lambda" {
  source = "git@github.com:Nerdware-LLC/fixit-cloud-modules.git//AWS_Lambda"

  name    = "my-lambda-function"
  handler = "index.handler"
  runtime = "nodejs16.x"
  deployment_package_src = {
    image_uri = "${module.ECR.Repositories["Foo_ECR_Repo"].repository_url}:my-lambda-function_v1"
    # URI Format: [ACCOUNT_ID].dkr.ecr.[REGION].amazonaws.com/[REPO_NAME]:[TAG]
  }

  execution_role_arn = module.IAM.Roles["MyLambdaFnExecRole"].arn

  vpc_config = {
    security_group_ids = [
      for sec_grp_name, sec_grp in module.VPC.Security_Groups : sec_grp.id
      if sec_grp_name == "my-lambda-fn-security-group"
    ]
    subnet_ids = [
      for cidr, subnet in module.VPC.Subnets : subnet.id
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
      source_arn   = module.EventBridge.Event_Rules["run-every-30-mins"].arn
    }
  }
}

######################################################################
