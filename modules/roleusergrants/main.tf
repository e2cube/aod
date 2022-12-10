
terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.53"
      configuration_aliases = [snowflake.role]
    }
  }
}

resource "snowflake_role_grants" "grants" {
    for_each = var.roles
    provider  = snowflake.role
    role_name = each.value
    users     = [var.user]
}