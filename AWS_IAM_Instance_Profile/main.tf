######################################################################
### EC2 Instance Profile

resource "aws_iam_instance_profile" "this" {
  name = var.name
  role = aws_iam_role.this.name
  path = var.path
  tags = var.tags
}

resource "aws_iam_role" "this" {
  name        = var.iam_role.name
  description = var.iam_role.description
  path        = coalesce(var.iam_role.path, "/")
  tags        = var.iam_role.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "map" {
  for_each = {
    for policy in coalesce(var.iam_role.custom_iam_policies, []) : policy.policy_name => policy
  }

  name        = each.key
  policy      = each.value.policy_json
  description = each.value.description
  path        = coalesce(each.value.path, "/")
  tags        = each.value.tags
}

resource "aws_iam_role_policy_attachment" "set" {
  for_each = toset(flatten([
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", # For SSM
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",  # For CloudWatch-Agent usage
    coalesce(var.iam_role.policy_arns, []),                 # User-provided policy ARNs
    [for policy in values(aws_iam_policy.map) : policy.arn] # User-provided new custom policy ARNs
  ]))

  role       = aws_iam_role.this.name
  policy_arn = each.key
}

#---------------------------------------------------------------------
### EC2 Key Pair (optional)

resource "aws_key_pair" "this" {
  count = var.ec2_key_pair != null ? 1 : 0

  key_name   = var.ec2_key_pair.key_name
  public_key = var.ec2_key_pair.public_key
  tags       = var.ec2_key_pair.tags

  lifecycle {
    /* "public_key" must be ignored bc the AWS API does not include
    the field in the response, so `terraform apply` would otherwise
    always attempt to replace the key pair.  */
    ignore_changes = [public_key]
  }
}

######################################################################
