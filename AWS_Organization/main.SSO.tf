######################################################################
### AWS SSO

# Our AWS SSO Identity Store instance:
data "aws_ssoadmin_instances" "this" {}

# The SSO PermSet to which we'll attach the AdministratorAccess managed IAM policy
resource "aws_ssoadmin_permission_set" "AdministratorAccess" {
  name = coalesce(
    var.admin_sso_config.permission_set_name,
    "AdministratorAccess"
  )
  description  = var.admin_sso_config.permission_set_description
  instance_arn = one(data.aws_ssoadmin_instances.this.arns)
  session_duration = (var.admin_sso_config.session_duration != null
    ? "PT${var.admin_sso_config.session_duration}H"
    : "PT12H"
  )
  tags = var.admin_sso_config.permission_set_tags
}

# Attach the AdministratorAccess managed IAM policy to the above PermSet
resource "aws_ssoadmin_managed_policy_attachment" "AdministratorAccess" {
  instance_arn       = one(data.aws_ssoadmin_instances.this.arns)
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  permission_set_arn = aws_ssoadmin_permission_set.AdministratorAccess.arn
}

# SSO Admins Group
data "aws_identitystore_group" "Admins_SSO_Group" {
  identity_store_id = one(data.aws_ssoadmin_instances.this.identity_store_ids)

  filter {
    attribute_path  = "DisplayName"
    attribute_value = var.admin_sso_config.sso_group_name
  }
}

# Assign accounts to Admins SSO Group
resource "aws_ssoadmin_account_assignment" "map" {
  for_each = aws_organizations_account.map # keys --> account names

  instance_arn       = aws_ssoadmin_permission_set.AdministratorAccess.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.AdministratorAccess.arn

  principal_type = "GROUP"
  principal_id   = data.aws_identitystore_group.Admins_SSO_Group.group_id

  target_type = "AWS_ACCOUNT"
  target_id   = each.value.id
}

######################################################################
