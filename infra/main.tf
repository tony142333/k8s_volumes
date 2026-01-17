provider "aws" {
  region = "us-east-1"
}

# 1. THE SECURITY GROUP (The "Firewall Rules")
resource "aws_security_group" "k8s_sg" {
  name        = "k8s-project-sg"
  description = "Allow SSH, Web, and K8s API"

  # SSH for you to enter the server
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Web Traffic (Ingress)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # K8s API (so your laptop's kubectl can talk to it)
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress: Allow the server to download K3s/Docker from the internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. THE EC2 INSTANCE
resource "aws_instance" "k8s_node" {
  ami           = "ami-0ecb62995f68bb549" # Ubuntu 22.04 LTS (Update for your region)
  instance_type = "t3.medium"
  key_name      = "tejav" # Change this to your existing AWS Key Pair name

  vpc_security_group_ids = [aws_security_group.k8s_sg.id]

  # 3. AUTO-INSTALL K3S & DOCKER
  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y docker.io
              # Install K3s (Lightweight K8s)
              curl -sfL https://get.k3s.io | sh -
              # Give permissions to the config file
              chmod 644 /etc/rancher/k3s/k3s.yaml
              EOF

  tags = {
    Name = "K8s-FullStack-Project"
  }
}

output "public_ip" {
  value = aws_instance.k8s_node.public_ip
}
