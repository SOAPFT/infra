#!/bin/bash

# 로그 파일 설정
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "User data script started at $(date)"

# 시스템 업데이트 먼저 수행
yum update -y

# ECS 클러스터에 등록
echo ECS_CLUSTER=${cluster_name} >> /etc/ecs/ecs.config

# 로그 드라이버 설정
echo ECS_AVAILABLE_LOGGING_DRIVERS='["json-file","awslogs"]' >> /etc/ecs/ecs.config

# 컨테이너 인스턴스 속성 설정
echo ECS_ENABLE_CONTAINER_METADATA=true >> /etc/ecs/ecs.config

# ECS 로그 레벨 설정
echo ECS_LOGLEVEL=info >> /etc/ecs/ecs.config

# Docker 데몬 시작
systemctl enable docker
systemctl start docker

# Docker가 완전히 시작될 때까지 대기
sleep 10

# ECS 에이전트 시작
systemctl enable ecs
systemctl restart ecs

# ECS 에이전트 상태 확인
sleep 5
systemctl status ecs

# 유용한 도구들 설치
yum install -y htop tree vim curl wget

# 디버깅용 PostgreSQL 클라이언트 설치
amazon-linux-extras install -y postgresql13

echo "User data script completed at $(date)"