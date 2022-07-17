######################################################################
### AWS IAM
######################################################################
### IAM Policies

resource "aws_iam_policy" "map" {
  for_each = var.custom_iam_policies

  name        = each.key
  policy      = each.value.policy_json
  description = each.value.description
  path        = coalesce(each.value.path, "/")
  tags        = each.value.tags
}

#---------------------------------------------------------------------
### IAM Roles

resource "aws_iam_role" "map" {
  for_each = var.iam_roles

  name        = each.key
  description = each.value.description
  path        = coalesce(each.value.path, "/")
  tags        = each.value.tags

  assume_role_policy = (
    each.value.service_assume_role != null
    ? jsonencode({
      Version = "2012-10-17"
      Statement = {
        Effect = "Allow"
        Principal = {
          Service = each.value.service_assume_role
        }
        Action = "sts:AssumeRole"
      }
    })
    : each.value.assume_role_policy_json
  )
}

#---------------------------------------------------------------------
### IAM Service-Linked Roles

resource "aws_iam_service_linked_role" "map" {
  for_each = var.iam_service_linked_roles

  aws_service_name = each.key
  description      = each.value.description
  tags             = each.value.tags
}

#---------------------------------------------------------------------
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

#---------------------------------------------------------------------
### IAM Role Policy Attachments

resource "aws_iam_role_policy_attachment" "map" {
  /* Since neither role names nor policy names/ARNs can serve as unique keys
  within a map, we use both in combination to create keys out of jsonencoded
  objects with keys "role" and "policy_arn". Note if user provided a policy
  name, the ARN is obtained from the aws_iam_policy resource.  */
  for_each = toset(flatten([
    for role_name, role_config in var.iam_roles : [
      for policy_name_or_arn in role_config.policies : jsonencode({
        role = role_name
        policy_arn = (
          can(aws_iam_policy.map[policy_name_or_arn])
          ? aws_iam_policy.map[policy_name_or_arn].arn # <-- if policy was created in same module call
          : policy_name_or_arn                         # <-- if policy is the ARN of an existing policy
        )
      })
    ]
  ]))

  role       = jsondecode(each.value).role
  policy_arn = jsondecode(each.value).policy_arn

  /* The purpose of this depends_on is to ensure all referenced role/policy
  resources exist before requests are submitted to attach them.  */
  depends_on = [aws_iam_role.map, aws_iam_policy.map]
}

######################################################################
