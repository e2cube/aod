locals {
    # decode the yaml file 
    yaml_file = yamldecode(file("C:\\Users\\bmachava\\repos\\articles\\snowflake\\parameters.yaml"))
    
    db = local.yaml_file["database"]

    # decide on database name based on env variable passed to terraform  
    db_name = var.env == "PROD" ? local.db.name : "${local.db.name}_${var.env}"

    # parse landing schemas 
    db_landing_schemas = flatten([for schema in local.yaml_file["landing-schemas"]: 
        {
                database = local.db_name # name of the db this schema lives in 
                name   = schema.name
        }
    ])   
    # get the domain schemas 
    db_domain_schemas = flatten([for schema in local.yaml_file["domain-schemas"]: 
        [for suffix in local.yaml_file["domain-schema-suffix"]:
            {
                    database = local.db_name # name of the db this schema lives in 
                    name   = "${schema.name}_${suffix}"
            }
        ]
    ])
    # create access roles and assign privileges 
    db_access_roles = [for role in local.yaml_file["access_roles"]:
        {
            database = local.db_name
            role_name = role.name
            write_access = toset(lookup(role, "write_access", [])) 
            read_access = toset(lookup(role, "read_acces", []))
        }
    ]
    # map existing users to roles
    db_user_roles = [for user in local.yaml_file["user-roles-mapping"]:
        {
            name = user.name
            roles = toset(lookup(user, "roles", []))
        }
    ]
}
