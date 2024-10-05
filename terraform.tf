resource "aws_vpc" "cloudjaider" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "cloudjaider"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id = aws_vpc.cloudjaider.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    "Name"="public_subnet_1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id = aws_vpc.cloudjaider.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
  tags = {
    "Name"="public_subnet_2"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id = aws_vpc.cloudjaider.id
  cidr_block = "10.0.3.0/24"
  availability_zone       = "us-east-1a"
  tags = {
    "Name"="private_subnet_1"
  }

  depends_on = [ 
    aws_subnet.public_subnet_1
   ]
}


resource "aws_subnet" "private_subnet_2" {
  vpc_id = aws_vpc.cloudjaider.id
  cidr_block = "10.0.4.0/24"
  availability_zone       = "us-east-1b"
  tags = {
    "Name"="private_subnet_2"
  }

  depends_on = [ 
    aws_subnet.public_subnet_2
   ]
}

resource "aws_internet_gateway" "igw" {
 vpc_id=aws_vpc.cloudjaider.id

 tags = {
    Name="igw jaider"
 }
}

resource "aws_route_table" "public_crt" {
  vpc_id = aws_vpc.cloudjaider.id

  route{
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name="public crt"
  }
}


resource "aws_route_table_association" "crta_public_subnet_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_crt.id
}

resource "aws_route_table_association" "crta_public_subnet_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_crt.id
}

resource "aws_security_group" "sg_public_instance" {
    name = "Public  Instance SG"
    description = "Allow SSH inbound traffic and ALL egress traffic"
    vpc_id = aws_vpc.cloudjaider.id

    ingress{
        description = "SSH over Internet"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    egress{
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    tags = {
        Name="Public Instance SG"
    }
}