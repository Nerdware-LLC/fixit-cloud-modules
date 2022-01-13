######################################################################
### AWS Service IP Ranges

data "aws_ip_ranges" "ec2_instance_connect" {
  regions  = [data.aws_region.current.name]
  services = ["ec2_instance_connect"]
}

data "aws_ip_ranges" "cloudfront" {
  regions  = ["global"] # cloudfront is the only service that accepts this "global" param
  services = ["cloudfront"]
}

locals {
  AWS_SERVICE_CIDRs = {
    EC2_INSTANCE_CONNECT = data.aws_ip_ranges.ec2_instance_connect.cidr_blocks
    CLOUDFRONT           = data.aws_ip_ranges.cloudfront.cidr_blocks
  }
  /* So far, every region+service filter combination we've implemented returns
  just one CIDR string in a list. Therefore, we COULD use the one() fn here to
  extract the CIDR strings from their respective lists, however, a future filter
  combination may return MULTIPLE CIDRs, so we will have this local keep the CIDRs
  in their lists to ensure the usage remains consistent over time.  */
}

/* NOTE: data.aws_ip_ranges
If the combination of region+service filters don't return ANY CIDR blocks, TF will error out.

DOCS: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ip_ranges

Complete List of Allowed Values for "services" Params:

amazon (for amazon.com)
amazon_connect
api_gateway
cloud9
cloudfront
codebuild
dynamodb
ec2
ec2_instance_connect
globalaccelerator
route53
route53_healthchecks
s3
workspaces_gateways
*/

######################################################################
