# Author: InferenceFailed Developers
# Created on: 29/12/2023
output "ipv4_address" {
  value = aws_instance.wireguard_instance.public_ip
}
