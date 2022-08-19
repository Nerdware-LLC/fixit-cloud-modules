######################################################################
### AWS IAM
######################################################################
### IAM Instance Profiles

resource "aws_iam_instance_profile" "map" {
  for_each = var.instance_profiles

  name = each.key
  path = each.value.path
  role = (
    each.value.role_name != null
    ? aws_iam_role.map[each.value.role_name].name # <-- if role was created in same module call
    : each.value.role_arn                         # <-- if role is the ARN of an existing role
  )
  tags = each.value.tags

  /* The purpose of this depends_on is so users can pass "role_name" in
  their instance profiles to create both resources in a single apply. */
  depends_on = [aws_iam_role.map]
}

######################################################################
