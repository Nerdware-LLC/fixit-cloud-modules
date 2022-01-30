######################################################################
### EC2 Instance Profile

resource "aws_iam_instance_profile" "this" {
  name = var.name
  role = aws_iam_role.this.name
  path = coalesce(var.path, "/")
  tags = var.tags
}

resource "aws_iam_role" "this" {
  name        = var.iam_role.name
  description = var.iam_role.description
  path        = coalesce(var.iam_role.path, "/")
  tags        = var.iam_role.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "map" {
  for_each = {
    for policy in var.iam_role.custom_iam_policies : policy.policy_name => policy
  }

  name        = each.key
  policy      = each.value.policy_json
  description = each.value.description
  path        = coalesce(each.value.path, "/")
  tags        = each.value.tags
}

resource "aws_iam_role_policy_attachment" "set" {
  for_each = toset(flatten([
    var.iam_role.policy_arns,
    [for policy_name, custom_policy in aws_iam_policy.map : custom_policy.arn]
  ]))

  role       = aws_iam_role.this.name
  policy_arn = each.key
}

######################################################################
