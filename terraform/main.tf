provider "aws" {
  region = var.region
}

resource "aws_instance" "example" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = "ExampleInstance"
  }
}

resource "aws_security_group" "example" {
  name        = "example_sg"
  description = "Allow SSH and HTTP traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_deployment" "node_server" {
  metadata {
    name = "node-server"
    labels = {
      app = "node-server"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "node-server"
      }
    }

    template {
      metadata {
        labels = {
          app = "node-server"
        }
      }

      spec {
        container {
          image = "<your-container-registry>/node-server:latest" # Reemplaza con tu imagen
          name  = "node-server"

          port {
            container_port = 3000
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "node_server_service" {
  metadata {
    name = "node-server-service"
  }

  spec {
    selector = {
      app = "node-server"
    }

    port {
      protocol    = "TCP"
      port        = 3000
      target_port = 3000
    }

    type = "LoadBalancer"
  }
}