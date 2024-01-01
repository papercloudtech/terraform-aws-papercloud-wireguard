# Author: InferenceFailed Developers
# Created on: 29/12/2023
variable "ami_id" {
  type    = string
  default = "ami-03f4878755434977f" # Ubuntu 22.04 LTS (jammy)
}

variable "github_organization" {
  type    = string
  default = "InferenceFailed"
}

variable "github_repository" {
  type    = string
  default = "wireguard-server"
}

variable "github_pat" {
  type      = string
  sensitive = true
}
