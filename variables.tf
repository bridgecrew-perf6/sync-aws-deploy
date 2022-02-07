variable "region" {
  type = string
}
variable "team" {
  type = string
}
variable "creator" {
  type = string
}
variable "ami" {
  type = string
}
variable "instance_type" {
  type = string
}
variable "namespace" {
  type = string
}
variable "source_subnet" {
  type = string
}
variable "key_name" {
  type = string
}
variable "secrets" {
  type = map(any)
  default = {
    "foo" = "bar"
  }
}
# variable "secret_map" {
#   description = "A Key/Value map of secrets that will be added to AWS Secrets"
#   type        = map(string)
# }

# variable "default_tags" {
#   description = "Tags to be applied to resources"
# }

# variable "secret_retention_days" {
#   default     = 0
#   description = "Number of days before secret is actually deleted. Increasing this above 0 will result in Terraform errors if you redeploy to the same workspace."
# }
