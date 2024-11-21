terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>3.0"
    }
  }
}
#proveedor de servicios 
provider "aws" {
  region     = "us-east-1"

}

resource "aws_instance" "ec2_public" { #creacion instancia test con linux 2
  ami           = "ami-0984f4b9e98be44bf"
  instance_type = "t2.micro"
  tags = {
    Name = "ec2_public"
  }
}