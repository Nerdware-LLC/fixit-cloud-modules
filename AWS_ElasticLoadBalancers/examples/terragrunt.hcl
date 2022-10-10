######################################################################
### EXAMPLE USAGE: AWS_ElasticLoadBalancing

/* As in any Terragrunt configuration, the inputs below can be
provided in a single standalone resource config, or may be broken up
across multiple resource configs and utilized with a combination of
include-blocks and/or the read_terragrunt_config() Terragrunt fn. */

#---------------------------------------------------------------------
### Dependencies

dependency "Foo_VPC" {
  config_path = "${get_terragrunt_dir()}/../Foo_VPC"
}

#---------------------------------------------------------------------
### Inputs

inputs = {
  load_balancers = {
    Simple_ALB = {
      type = "application"

      subnets = {
        FooPrivateSubnet_in_useast2a = {
          subnet_id = dependency.Foo_VPC.outputs.Subnets.FooPrivateSubnet_A.id
        }
        FooPrivateSubnet_in_useast2b = {
          subnet_id = dependency.Foo_VPC.outputs.Subnets.FooPrivateSubnet_B.id
        }
      }

      alb_security_group_ids = [
        dependency.Foo_VPC.outputs.SecurityGroups["ALB_SecGrp"].id
      ]
    }
  }

  listeners = {
    # "listeners" keys are arbitrary, they're used internally and won't manifest anywhere in your infra.
    Foo_Simple_ALB_HTTPS_Listener = {
      load_balancer_name = "Simple_ALB"
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = "arn:aws:iam::111111111111:server-certificate/test_cert_1a1a1a1a1a1a1a1a1a1a1a1a1a"
      ssl_policy         = "ELBSecurityPolicy-2016-08"
      actions = [
        {
          # RULE 1: Forward traffic
          type              = "forward"
          is_default_action = true # <-- every listener must have at least 1 default action
          priority          = 10
          forward = {
            target_groups = [
              {
                name = "Foo_ECS_Service"
              }
            ]
          }
        },
        {
          # RULE 2: Send fixed-response if path is "/say-hi"
          type     = "fixed-response"
          priority = 1
          fixed_response = {
            status_code  = "2XX"
            content_type = "text/plain"
            message_body = "Hello there!"
          }
          conditions = [
            {
              path_patterns = ["/say-hi"]
            }
          ]
        }
      ]
    }
  }

  target_groups = {
    Foo_ECS_Service = {
      target_type               = "ip"
      port                      = 80
      protocol                  = "HTTP"
      protocol_version          = "HTTP2"
      slow_start_warmup_seconds = 10
      # ECS services register containers on your behalf - don't register such targets here!
    }
  }
}

######################################################################
