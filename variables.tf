# Author: PaperCloud Developers
# Created on: 29/12/2023
variable "github_organization" {
  type    = string
  default = "papercloudtech"
}

variable "github_repository" {
  type    = string
  default = "wireguard-server"
}

variable "aws_access_key_id" {
  type      = string
  sensitive = true
}

variable "aws_secret_access_key" {
  type      = string
  sensitive = true
}
