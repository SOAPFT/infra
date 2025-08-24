# EC2 인스턴스용 보안 그룹
resource "aws_security_group" "ec2_ecs" {
  name_prefix = "${var.project_name}-${var.environment}-ec2-ecs-"
  vpc_id      = var.vpc_id

  # ALB에서 접근하는 컨테이너 포트
  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  # ECS 작업 동적 포트 범위
  ingress {
    from_port       = 32768
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2-ecs-sg"
  }
}

# RDS 접근 규칙은 networking 모듈에서 CIDR 블록으로 관리됨

# ECS AMI
data "aws_ssm_parameter" "ecs_al2_image_id" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

# EC2 인스턴스용 IAM 역할
resource "aws_iam_role" "ec2_ecs_instance_role" {
  name = "${var.project_name}-${var.environment}-ec2-ecs-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2-ecs-instance-role"
  }
}

# IAM 정책 연결
resource "aws_iam_role_policy_attachment" "ec2_ecs_instance_role_policy" {
  role       = aws_iam_role.ec2_ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# SSM Session Manager 정책 연결
resource "aws_iam_role_policy_attachment" "ec2_ssm_managed_instance_core" {
  role       = aws_iam_role.ec2_ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# IAM 인스턴스 프로파일
resource "aws_iam_instance_profile" "ec2_ecs_instance_profile" {
  name = "${var.project_name}-${var.environment}-ec2-ecs-instance-profile"
  role = aws_iam_role.ec2_ecs_instance_role.name

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2-ecs-instance-profile"
  }
}

# Launch Template
resource "aws_launch_template" "ec2_ecs" {
  name_prefix   = "${var.project_name}-${var.environment}-ec2-ecs-"
  image_id      = data.aws_ssm_parameter.ecs_al2_image_id.value
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.ec2_ecs.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_ecs_instance_profile.name
  }

  key_name = var.key_pair_name  # SSH 키 페어 (옵션)

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "optional"  # 문제 해결 후 "required"로 복원 권장
    http_put_response_hop_limit = 2
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    cluster_name = var.cluster_name
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-${var.environment}-ecs-instance"
    }
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2-ecs-lt"
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "ec2_ecs" {
  name                = "${var.project_name}-${var.environment}-ec2-ecs-asg"
  vpc_zone_identifier = var.private_subnet_ids
  min_size            = 1
  max_size            = 3
  desired_capacity    = var.desired_capacity

  launch_template {
    id      = aws_launch_template.ec2_ecs.id
    version = "$Latest"
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300
  protect_from_scale_in     = false

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = false
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}-ecs-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project_name
    propagate_at_launch = true
  }
}

# ECS Capacity Provider
resource "aws_ecs_capacity_provider" "ec2" {
  name = "${var.project_name}-${var.environment}-ec2-cp"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ec2_ecs.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      status          = "ENABLED"
      target_capacity = 100
    }
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2-cp"
  }
}