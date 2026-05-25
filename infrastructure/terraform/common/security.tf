module "security" {
  source = "../modules/security"

  name_prefix = local.name_prefix
  tags        = local.common_tags
}
