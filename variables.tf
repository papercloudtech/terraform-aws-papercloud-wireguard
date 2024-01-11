# Author: InferenceFailed Developers
# Created on: 29/12/2023
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
