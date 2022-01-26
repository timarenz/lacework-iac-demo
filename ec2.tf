data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "web" {
  name        = "web-sg-${random_id.id.hex}"
  description = "Allow some inbound and all outbound traffic"
  vpc_id      = module.environment.vpc_id

  ingress {
    description = "HTTP from everywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from everywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${lookup(jsondecode(data.http.current_ip.body), "ip")}/32"]
  }

  egress {
    description      = "outbound to everywhere"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    owner       = var.owner_name
    environment = var.environment_name
  }
}

resource "random_shuffle" "public_subnet" {
  input        = module.environment.public_subnet_ids
  result_count = 1
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.nano"

  vpc_security_group_ids = [aws_security_group.web.id]
  subnet_id              = random_shuffle.public_subnet.result
  user_data              = <<EOF
#! /bin/bash
sudo apt-get update
sudo apt-get install -y nginx
export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
export AWS_SECRET_ACCESS_KEY=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
export AWS_DEFAULT_REGION=${var.aws_region}
echo "<h1>Unsecure VM instance provisioned via Terraform</h1>" | sudo tee /var/www/html/index.html
EOF

  tags = {
    Name        = "web-${random_id.id.hex}"
    owner       = var.owner_name
    environment = var.environment_name
  }
}
