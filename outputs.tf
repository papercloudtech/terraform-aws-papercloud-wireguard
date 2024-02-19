# Author: PaperCloud Developers
# Created on: 29/12/2023
output "ami_id" {
  value = data.aws_ami.ubuntu.image_id
}

output "ipv4_address" {
  value = aws_instance.wireguard_instance.public_ip
}
