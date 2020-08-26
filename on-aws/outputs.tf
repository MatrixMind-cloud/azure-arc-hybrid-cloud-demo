
output "windows_instance_details" {
  # don't do this at home! store in vault instead!
  value = [for i in aws_instance.windows : {
    "instance"   = i.id
    "private_ip" = i.private_ip
    "password"   = rsadecrypt(i.password_data, tls_private_key.windows.private_key_pem)
  }]
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}
