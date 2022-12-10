variable "db" {
    type = string
}
variable "write_schema" {
    type = set(string)
}
variable "read_schema" {
    type = set(string)
}
variable "role" {
    type = string
}