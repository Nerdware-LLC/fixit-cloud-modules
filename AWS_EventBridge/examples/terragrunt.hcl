######################################################################
### EXAMPLE USAGE: AWS_EventBridge

/* As in any Terragrunt configuration, the inputs below can be
provided in a single standalone resource config, or may be broken up
across multiple resource configs and utilized with a combination of
include-blocks and/or the read_terragrunt_config() Terragrunt fn. */

#---------------------------------------------------------------------
### Dependencies

dependency "AWS_Org" {
  config_path = "${get_terragrunt_dir()}/../AWS_Org"
}

#---------------------------------------------------------------------
### Inputs

inputs = {

  event_buses = {
    "foo-custom-event-bus" = {
      event_bus_policy_statements = [
        {
          sid    = "OrganizationAccess"
          effect = "Allow"
          principals = {
            AWS = [
              for account_id in dependency.AWS_Org.outputs.Organization.accounts[*].id
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
              "aws:PrincipalOrgID" = [dependency.AWS_Org.outputs.Organization.id]
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
