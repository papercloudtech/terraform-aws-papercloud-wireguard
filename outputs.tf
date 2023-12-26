output "ipv4_address" {
  value = aws_instance.wireguard_instance.public_dns
}
