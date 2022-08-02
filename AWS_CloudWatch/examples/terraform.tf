######################################################################
### EXAMPLE USAGE: AWS_CloudWatch

module "AWS_CloudWatch" {
  source = "git@github.com:Nerdware-LLC/fixit-cloud-modules.git//AWS_CloudWatch"

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
              ["AWS/EC2", "CPUUtilization", "InstanceId", "i-012345"]
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
