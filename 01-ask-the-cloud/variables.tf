# Inputs to the project. Each has a default, so you don't have to pass anything.
# Override one with e.g. `terraform plan -var="project_name=my-app"`.

variable "project_name" {
  description = "Prefix used in resource names"
  type        = string
  default     = "ask-the-cloud"
}

variable "region" {
  description = "AWS region to deploy into (your account is fixed to eu-north-1)"
  type        = string
  default     = "eu-north-1"
}
