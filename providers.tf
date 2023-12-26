provider "aws" {
  shared_config_files      = ["/home/pi/.aws/config"]
  shared_credentials_files = ["/home/pi/.aws/credentials"]
  profile                  = "default"
}
