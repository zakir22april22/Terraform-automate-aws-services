#VPC CREATE
resource "aws_vpc" "myvpc" {
    cidr_block = var.cidr
}

#PUBLIC-SUBNET
resource "aws_subnet" "sub1" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = var.cidr1
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true

    tags = {
    Name = "public-subnet1"
  }
}

resource "aws_subnet" "sub2" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = var.cidr2
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = true
    
    tags = {
    Name = "public-subnet2"
  }
}

#INTERNET-GATEWAY
resource "aws_internet_gateway" "myigw" {
    vpc_id = aws_vpc.myvpc.id
    tags = {
    Name = "myigw"
  }
}

#ROUTE-TABLE
resource "aws_route_table" "RT" {
    vpc_id = aws_vpc.myvpc.id

    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }
  
}

#ROUTE-TABLE-ASSOCIATION
resource "aws_route_table_association" "rts1" {
    subnet_id = aws_subnet.sub1.id
    route_table_id = aws_route_table.RT.id

  
}
resource "aws_route_table_association" "rts2" {
    subnet_id = aws_subnet.sub2.id
    route_table_id = aws_route_table.RT.id

  
}

#SECURITY-GROUP
resource "aws_security_group" "sg" {
  name        = "web-sg"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description      = "http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}

#S3-BUCKET
resource "aws_s3_bucket" "s3-bucket" {
    bucket = "05-02-1997-bucket"
}

#EC2-INSTANCE CREATE
resource "aws_instance" "webserver1" {
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id = aws_subnet.sub1.id
  user_data = base64encode(file(("userdata.sh")))
}

resource "aws_instance" "webserver2" {
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id = aws_subnet.sub2.id
  user_data = base64encode(file(("userdata1.sh")))
}

