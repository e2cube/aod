terraform {
    required_providers {
        snowflake = {
        source  = "Snowflake-Labs/snowflake"
        version = "0.53"
        }
    }
}
provider "snowflake" {
    role  = "SYSADMIN"
    alias = "SYSADMIN"
}

resource "snowflake_warehouse" "warehouse" {
    provider        = snowflake.SYSADMIN
    name            = "DEMO"
    warehouse_size  = "xsmall"
    auto_suspend    = 5
}

resource "snowflake_database" "db" {
  provider = snowflake.SYSADMIN
  name     = local.db_name
}

provider "snowflake" {
    alias = "security_admin"
    role  = "SECURITYADMIN"
}

resource "snowflake_schema" "lanidng_schemas" {
    for_each = { for entry in local.db_landing_schemas: "${entry.database}.${entry.name}" => entry }
    provider = snowflake.SYSADMIN
    database = each.value.database 
    name     = each.value.name
    is_managed = false
    depends_on = [
      snowflake_database.db
    ]
}

resource "snowflake_schema" "domain_schemas" {
    for_each = { for entry in local.db_domain_schemas: "${entry.database}.${entry.name}" => entry }
    provider = snowflake.SYSADMIN
    database = each.value.database 
    name     = each.value.name
    is_managed = false
    depends_on = [
      snowflake_database.db
    ]
}

module provision_roles {
    source = "./modules/roleschemagrant/"
    providers = {
        snowflake.role = snowflake.security_admin
    }
    for_each = {for entry in local.db_access_roles: entry.role_name => entry }
    db = each.value.database
    read_schema = each.value.read_access
    write_schema = each.value.write_access
    role = each.value.role_name
    depends_on = [
      snowflake_schema.domain_schemas,
      snowflake_schema.lanidng_schemas
    ]
}

module map_user_to_roles {
    source = "./modules/roleusergrants/"
    providers = {
        snowflake.role = snowflake.security_admin
    }
    for_each = {for entry in local.db_user_roles: entry.name => entry }
    user = each.value.name
    roles = each.value.roles
    depends_on = [
      module.provision_roles
    ]
}