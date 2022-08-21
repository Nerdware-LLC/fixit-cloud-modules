######################################################################
### EXAMPLE USAGE: AWS_Lambda
######################################################################

module "ECR" {
  /* dependency inputs */
}

module "DynamoDB" {
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

  execution_role = {
    name = "my-lambda-exec-role"
    attach_policy_arns = [
      /* This managed policy allows the Lambda function to create a CloudWatch
      Log Group named "/aws/lambda/[FUNCTION_NAME]" and upload logs to it.  */
      "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    ]
    attach_policies = {
      AllowDynamoDBaccess = {
        description = "Allow Lambda fn to have R/W access to Foo_DynamoDB_Table."
        statements = [{
          effect = "Allow"
          actions = [
            "dynamodb:GetItem",
            "dynamodb:BatchGetItem",
            "dynamodb:PutItem",
            "dynamodb:UpdateItem",
            "dynamodb:BatchWriteItem",
            "dynamodb:Query",
            "dynamodb:Scan"
          ]
          resources = [module.DynamoDB.Table.arn]
        }]
      }
    }
  }

  environment_variables = {
    AWS_REGION          = "us-west-1"
    DYNAMODB_TABLE_NAME = module.DynamoDB.Table.name
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
