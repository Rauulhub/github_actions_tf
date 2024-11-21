terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.76.0"
    }
  }
}
terraform {
  backend "s3" {
    bucket = "lab-tf-gh"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
#proveedor de servicios 
provider "aws" {
  region = "us-east-1"

}
#networking
resource "aws_vpc" "lab_vpc" {
  cidr_block = "10.1.0.0/26"
  tags = {
    Name = "lab_vpc"
  }
}

resource "aws_subnet" "subnet_public" {
  vpc_id     = aws_vpc.lab_vpc.id
  cidr_block = "10.1.0.0/28"
  tags = {
    Name = "subnet_public"
  }
}
resource "aws_subnet" "subnet_private" {
  vpc_id     = aws_vpc.lab_vpc.id
  cidr_block = "10.1.0.16/28"
  tags = {
    Name = "subnet_private"
  }
}

resource "aws_internet_gateway" "lab_internet_gw" {
  vpc_id = aws_vpc.lab_vpc.id
  tags = {
    Name = "lab_internet_gw"
  }
}

resource "aws_route_table" "internet" {
  vpc_id = aws_vpc.lab_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab_internet_gw.id
  }
  tags = {
    Name = "internet"
  }
}

resource "aws_route_table_association" "public_routetable" {
  subnet_id      = aws_subnet.subnet_public.id
  route_table_id = aws_route_table.internet.id
}

resource "aws_eip" "nat_eip" {

}
resource "aws_nat_gateway" "lab_natgw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.subnet_public.id
  depends_on    = [aws_internet_gateway.lab_internet_gw]
}
resource "aws_route_table" "nat" {
  vpc_id = aws_vpc.lab_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.lab_natgw.id
  }
  tags = {
    Name = "nat"
  }
}
resource "aws_route_table_association" "private_routetable" {
  subnet_id      = aws_subnet.subnet_private.id
  route_table_id = aws_route_table.nat.id
}
#roles Iam y y configuracion para asociarlo a las Ec2
resource "aws_iam_role" "ec2-ssm" {
  name = "ec2-ssm"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}
resource "aws_iam_role_policy_attachment" "ec2-ssm-policy" {
  role       = aws_iam_role.ec2-ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_instance_profile" "ec2-profile_private" {
  name = "ec2_ssm_private"
  role = aws_iam_role.ec2-ssm.name
}
resource "aws_iam_instance_profile" "ec2-profile_public" {
  name = "ec2_ssm_public"
  role = aws_iam_role.ec2-ssm.name
}
#creacion Ec2 
resource "aws_instance" "ec2_private" { #creacion instancia test con linux 2
  ami                  = "ami-0984f4b9e98be44bf"
  instance_type        = "t2.micro"
  subnet_id            = aws_subnet.subnet_private.id
  iam_instance_profile = aws_iam_instance_profile.ec2-profile_private.name
  tags = {
    Name = "ec2_private"
  }

}
resource "aws_instance" "ec2_public" { #creacion instancia test con linux 2
  ami           = "ami-0984f4b9e98be44bf"
  instance_type = "t2.micro"

  subnet_id            = aws_subnet.subnet_public.id
  iam_instance_profile = aws_iam_instance_profile.ec2-profile_public.name
  tags = {
    Name = "ec2_public"
  }
}