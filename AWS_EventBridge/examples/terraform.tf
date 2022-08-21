######################################################################
### EXAMPLE USAGE: AWS_EventBridge

module "AWS_Org" {
  /* dependency inputs */
}

module "AWS_EventBridge" {
  source = "git@github.com:Nerdware-LLC/fixit-cloud-modules.git//AWS_EventBridge"

  event_buses = {
    "foo-custom-event-bus" = {
      event_bus_policy_statements = [
        {
          sid    = "OrganizationAccess"
          effect = "Allow"
          principals = {
            AWS = [
              for account_id in module.AWS_Org.Organization.accounts[*].id
              : "arn:aws:iam::${account_id}:root"
              /* AWS converts account ID principals to ARN format upon policy submission,
              so interpolate them as shown above to avoid a constant-diff problem.     */
            ]
          }
          actions = [
            "events:DescribeRule",
            "events:ListRules",
            "events:ListTargetsByRule",
            "events:ListTagsForResource",
          ]
          resources = [
            "arn:aws:events:eu-west-1:111111111111:rule/*",            # <-- existing rules, with wildcard
            "arn:aws:events:eu-west-1:111111111111:event-bus/default", # <-- existing event bus
            "foo-custom-event-bus"                                     # <-- will be replaced by the ARN in the final policy document
          ]
          conditions = {
            StringEquals = {
              "aws:PrincipalOrgID" = [module.AWS_Org.Organization.id]
            }
          }
        }
      ]
    }
  }

  event_rules = {
    "run-every-30-minutes" = {
      enabled             = true
      description         = "Invoke foo-lambda-function every 30 minutes"
      schedule_expression = "rate(30 minutes)" # <-- Equivalent to "cron(0/30 * * * * *)"
      event_bus_name      = "foo-custom-event-bus"
    }
  }
}

######################################################################
