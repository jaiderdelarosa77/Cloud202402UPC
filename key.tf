# Genera una clave privada RSA
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Crea una clave pública en AWS a partir de la clave privada generada
resource "aws_key_pair" "generated_key" {
  key_name   = "cloud2"
  public_key = tls_private_key.private_key.public_key_openssh
}

# Guarda la clave privada en un archivo .pem llamado 'cloud.pem'
resource "local_file" "private_key_pem" {
  content        = tls_private_key.private_key.private_key_pem
  filename       = "${path.module}/cloud2.pem"
  file_permission = "0600"
}
