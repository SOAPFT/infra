# Bastion Host Security Group
resource "aws_security_group" "bastion" {
  name_prefix = "${var.project_name}-${var.environment}-bastion-"
  vpc_id      = var.vpc_id

  # SSH access from anywhere (restrict to your IP in production)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-bastion-sg"
  }
}

# Latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Bastion Host EC2 Instance
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  key_name              = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.bastion.id]
  subnet_id             = var.public_subnet_ids[0]

  # Enable detailed monitoring
  monitoring = false

  # User data for basic setup
  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y postgresql
    
    # Create a simple script for RDS connection
    cat > /home/ec2-user/connect-rds.sh << 'SCRIPT'
    #!/bin/bash
    echo "Connecting to RDS PostgreSQL..."
    echo "Usage: psql -h ${var.rds_endpoint_host} -p 5432 -U ${var.database_username} -d ${var.database_name}"
    echo ""
    echo "For port forwarding from your local machine:"
    echo "ssh -i ~/.ssh/your-key.pem -L 5432:${var.rds_endpoint_host}:5432 ec2-user@$(curl -s http://169.254.169.254/latest/meta-data/public-ip)"
    SCRIPT
    
    chmod +x /home/ec2-user/connect-rds.sh
    chown ec2-user:ec2-user /home/ec2-user/connect-rds.sh
  EOF
  )

  tags = {
    Name = "${var.project_name}-${var.environment}-bastion"
  }
}

# Elastic IP for bastion host (optional but recommended)
resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-${var.environment}-bastion-eip"
  }

  depends_on = [aws_instance.bastion]
}