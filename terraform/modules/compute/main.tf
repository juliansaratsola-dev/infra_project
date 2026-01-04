# Compute module - EC2 instances for RKE2 cluster

# Get latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# RKE2 Server Nodes
resource "aws_instance" "rke2_server" {
  count                  = var.rke2_server_count
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type_server
  key_name               = var.key_name
  subnet_id              = var.public_subnet_ids[count.index % length(var.public_subnet_ids)]
  vpc_security_group_ids = [data.aws_security_group.rke2_nodes.id]
  
  root_block_device {
    volume_size = 50
    volume_type = "gp3"
    encrypted   = true
  }

  user_data = templatefile("${path.module}/user_data_server.sh", {
    node_index = count.index
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-rke2-server-${count.index + 1}"
    Environment = var.environment
    Role        = "rke2-server"
  }
}

# RKE2 Agent Nodes
resource "aws_instance" "rke2_agent" {
  count                  = var.rke2_agent_count
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type_agent
  key_name               = var.key_name
  subnet_id              = var.public_subnet_ids[count.index % length(var.public_subnet_ids)]
  vpc_security_group_ids = [data.aws_security_group.rke2_nodes.id]
  
  root_block_device {
    volume_size = 50
    volume_type = "gp3"
    encrypted   = true
  }

  user_data = templatefile("${path.module}/user_data_agent.sh", {
    node_index = count.index
    server_ip  = aws_instance.rke2_server[0].private_ip
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-rke2-agent-${count.index + 1}"
    Environment = var.environment
    Role        = "rke2-agent"
  }

  depends_on = [aws_instance.rke2_server]
}

# Data source for security group
data "aws_security_group" "rke2_nodes" {
  vpc_id = var.vpc_id
  
  filter {
    name   = "tag:Name"
    values = ["${var.project_name}-${var.environment}-rke2-nodes-sg"]
  }
}

data "aws_security_group" "lb" {
  vpc_id = var.vpc_id
  
  filter {
    name   = "tag:Name"
    values = ["${var.project_name}-${var.environment}-lb-sg"]
  }
}

# Application Load Balancer
resource "aws_lb" "rancher" {
  name               = "${var.project_name}-${var.environment}-rancher-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.lb.id]
  subnets            = var.public_subnet_ids

  tags = {
    Name        = "${var.project_name}-${var.environment}-rancher-lb"
    Environment = var.environment
  }
}

# Target Group for Rancher
resource "aws_lb_target_group" "rancher" {
  name     = "${var.project_name}-${var.environment}-rancher-tg"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200-399"
    path                = "/ping"
    port                = "traffic-port"
    protocol            = "HTTPS"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-rancher-tg"
    Environment = var.environment
  }
}

# Target Group Attachments
resource "aws_lb_target_group_attachment" "rancher" {
  count            = var.rke2_server_count
  target_group_arn = aws_lb_target_group.rancher.arn
  target_id        = aws_instance.rke2_server[count.index].id
  port             = 443
}

# HTTPS Listener (only create if SSL certificate is provided)
resource "aws_lb_listener" "https" {
  count             = var.ssl_certificate_arn != "" ? 1 : 0
  load_balancer_arn = aws_lb.rancher.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.ssl_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rancher.arn
  }
}

# HTTP Listener (redirect to HTTPS)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.rancher.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
