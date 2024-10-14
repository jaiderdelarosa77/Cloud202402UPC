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
    
    ingress {
        description = "HTTP over Internet"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "mysql over Internet"
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
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

resource "aws_lb" "web_lb" {
  name               = "web-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_public_instance.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  enable_deletion_protection = false

  tags = {
    Name = "web-load-balancer"
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.web_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "fixed-response"
    fixed_response {
      status_code = 200
      content_type = "text/plain"
      message_body = "OK"
    }
  }
}
resource "aws_lb_target_group" "web_target_group" {
  name     = "web-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.cloudjaider.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    protocol            = "HTTP"
  }

  tags = {
    Name = "web-target-group"
  }
}

resource "aws_lb_target_group_attachment" "tg_attachment_instance_1" {
  target_group_arn = aws_lb_target_group.web_target_group.arn
  target_id       = aws_instance.public_instance_1.id
  port            = 80
}

resource "aws_lb_target_group_attachment" "tg_attachment_instance_2" {
  target_group_arn = aws_lb_target_group.web_target_group.arn
  target_id       = aws_instance.public_instance_2.id
  port            = 80
}

resource "aws_db_subnet_group" "my_db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  tags = {
    Name = "my-db-subnet-group"
  }
}

resource "aws_db_instance" "rdsdb" {
  allocated_storage       = 20   
  storage_type            = "gp2"  
  engine                  = "mysql" 
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"  
  db_name                 = "mydb"
  username                = "admin"
  password                = "admin123" 
  multi_az                = false 
  publicly_accessible     = false
  backup_retention_period = 7 
  final_snapshot_identifier = "mydb-final-snapshot" 
  availability_zone       = "us-east-1a"

  db_subnet_group_name = aws_db_subnet_group.my_db_subnet_group.name
}