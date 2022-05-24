######################################################################
### AWS Service IP Ranges

# For more info, see the README section "CIDR Blocks: AWS Services"

data "aws_ip_ranges" "map" {
  for_each = toset([
    "amazon",               # Amazon (amazon.com)
    "amazon_connect",       # Amazon Connect
    "api_gateway",          # API Gateway
    "cloud9",               # Cloud9
    "cloudfront",           # CloudFront
    "cloudfront_global",    # CloudFront (global)
    "codebuild",            # CodeBuild
    "ec2",                  # EC2
    "ec2_instance_connect", # EC2 Instance Connect
    "dynamodb",             # DynamoDB
    "globalaccelerator",    # GlobalAccelerator
    "route53",              # Route53
    "route53_healthchecks", # Route53 HealthChecks
    "s3",                   # S3
    "workspaces_gateways"   # Workspaces Gateways
  ])

  # Check for "cloudfront_global" enum; if anything else, use provider region.
  regions  = [length(regexall("_global$", each.key)) > 0 ? "global" : data.aws_region.current.name]
  services = [each.key]
}

locals {

  # The only 2 supported for NACLs: ec2_instance_connect, globalaccelerator
  # The rest all return zero or multiple CIDRs.

  AWS_SERVICE_CIDRS = {
    for service_enum, ip_ranges in data.aws_ip_ranges.map : service_enum => ip_ranges.cidr_blocks
  }

}

######################################################################
