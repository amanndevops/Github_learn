provider "aws" {
  region = "us-east-1"  # AWS Region
}

resource "aws_instance" "minikube_instance" {
  ami           = "ami-084568db4383264d4"  # AMI ID
  instance_type = "t3.micro"
  key_name      = "macbook"
  security_groups = ["default"]

  user_data = file("install-minikube.sh")  # Updated script name

  tags = {
    Name = "MinikubeInstance"
  }
}
