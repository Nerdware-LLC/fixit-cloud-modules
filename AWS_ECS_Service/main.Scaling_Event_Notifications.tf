######################################################################
### ECS Scaling Event Notifications

# TODO Implement ECS Service scaling event notifications.

# "CloudWatch Events" / "EventBridge Events"

# resource "aws_cloudwatch_event_rule" "ECS_Service_Deployment" {
#   name          = "ECS_Service_Deployment_Change"
#   description   = "ECS Service Deployment state change event."
#   event_pattern = <<-EOF
#     {
#         "source": ["aws.ecs"],
#         "detail-type": ["ECS Deployment state change event"]
#     }
#     EOF
# }

#---------------------------------------------------------------------

# resource "aws_cloudwatch_event_target" "ECS_Service_Deployment" {
#   rule      = aws_cloudwatch_event_rule.ECS_Service_Deployment.name
#   target_id = "ECS_Service_Deployment"
#   arn       = var.ecs_service_deployment_sns_topic.arn
# }

######################################################################
