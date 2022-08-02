######################################################################
### EXAMPLE USAGE: AWS_CloudWatch

/* As in any Terragrunt configuration, the inputs below can be
provided in a single standalone resource config, or may be broken up
across multiple resource configs and utilized with a combination of
include-blocks and/or the read_terragrunt_config() Terragrunt fn. */

#---------------------------------------------------------------------
### Dependencies

dependency "Foo_EC2" {
  config_path = "${get_terragrunt_dir()}/../Foo_EC2"
}


#---------------------------------------------------------------------
### Inputs

inputs = {

  cloudwatch_dashboards = {
    My_Good_Dashboard = jsonencode({
      widgets = [
        {
          type   = "metric"
          x      = 0
          y      = 0
          width  = 12
          height = 6
          properties = {
            metrics = [
              ["AWS/EC2", "CPUUtilization", "InstanceId", dependency.Foo_EC2.outputs.EC2_Instance.id]
            ]
            period = 300
            stat   = "Average"
            region = "us-west-1"
            title  = "EC2 Instance CPU"
          }
        },
        {
          type   = "text"
          x      = 0
          y      = 7
          width  = 3
          height = 3
          properties = {
            markdown = "Hello world"
          }
        }
      ]
    })
  }
}

######################################################################
