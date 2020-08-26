
output "windows_instance_credentials" {
  # don't do this at home! store in vault instead!
  value = rsadecrypt(aws_instance.windows.password_data, tls_private_key.windows.private_key_pem)
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}
