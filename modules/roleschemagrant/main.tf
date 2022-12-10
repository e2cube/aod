
terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.53"
      configuration_aliases = [snowflake.role]
    }
  }
}

resource "snowflake_role" "dw_role" {
    provider = snowflake.role
    name     = var.role
}
resource "snowflake_schema_grant" "grant_write" {
  provider = snowflake.role
  for_each = var.write_schema
  database_name = "${var.db}"
  schema_name   = each.value
  privilege =  "CREATE TABLE"
  roles     = [snowflake_role.dw_role.name]
}

resource "snowflake_schema_grant" "grant_read" {
  provider = snowflake.role
  for_each = var.read_schema
  database_name = var.db
  schema_name   = each.value
  privilege = "USAGE"
  roles     = [snowflake_role.dw_role.name]
}
