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

dependency "DynamoDB" {
  config_path = "${get_terragrunt_dir()}/../Foo_DynamoDB_Table"
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
          resources = [dependency.DynamoDB.outputs.Table.arn]
        }]
      }
    }
  }

  environment_variables = {
    AWS_REGION          = "us-west-1"
    DYNAMODB_TABLE_NAME = dependency.DynamoDB.outputs.Table.name
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
