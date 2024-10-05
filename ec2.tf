resource "aws_instance" "public_instance_1" {
  ami = "ami-0aa7d40eeae50c9a9"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public_subnet_1.id
  vpc_security_group_ids = [aws_security_group.sg_public_instance.id]
  tags = {
    Name = "PublicInstanceWithoutKey1"
  }
}

resource "aws_instance" "public_instance_2" {
  ami = "ami-0aa7d40eeae50c9a9"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public_subnet_2.id
  vpc_security_group_ids = [aws_security_group.sg_public_instance.id]
  tags = {
    Name = "PublicInstanceWithoutKey2"
  }
}