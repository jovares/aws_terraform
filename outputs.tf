output "server_public_ip_address" {
  description = "Direccion IP"
  value       = aws_instance.nginx_instance.public_ip

}
output "server_public_ip_dns" {
  description = "Direccion IP"
  value       = aws_instance.nginx_instance.public_dns

}