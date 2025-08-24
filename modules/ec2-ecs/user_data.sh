#!/bin/bash
set -euxo pipefail
exec > >(tee -a /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1
echo "=== user-data start $(date -Is) ==="

# OS 탐지(템플릿 충돌 방지 위해 $ 이스케이프)
OS_NAME="$(. /etc/os-release; echo "$${NAME:-unknown}")"

# ECS 설정
echo "Writing ECS config with cluster: ${cluster_name}"
cat >/etc/ecs/ecs.config <<EOF
ECS_CLUSTER=${cluster_name}
ECS_ENABLE_CONTAINER_METADATA=true
ECS_LOGLEVEL=info
ECS_AVAILABLE_LOGGING_DRIVERS=["json-file","awslogs"]
EOF
echo "ECS config written:"
cat /etc/ecs/ecs.config

# 런타임 존재 시 enable/start (AL2= docker, AL2023= containerd)
has_service() {
  systemctl list-unit-files --type=service --all 2>/dev/null | awk '{print $1}' | grep -Fxq "$1" 2>/dev/null && return 0
  systemctl cat "$1" >/dev/null 2>&1 && return 0
  case "$1" in
    docker.service) command -v docker >/dev/null 2>&1 && return 0 ;;
    containerd.service) command -v containerd >/dev/null 2>&1 && return 0 ;;
  esac
  return 1
}

echo "Checking for docker.service..."
if has_service docker.service; then
  echo "Docker service found, enabling and starting..."
  systemctl enable docker || true
  systemctl start  docker || true
  sleep 10
else
  echo "Docker service not found"
fi

echo "Checking for containerd.service..."
if has_service containerd.service; then
  echo "Containerd service found, enabling and starting..."
  systemctl enable containerd || true
  systemctl start  containerd || true
else
  echo "Containerd service not found"
fi

# ecs.service drop-in
echo "Creating ECS service drop-in override..."
mkdir -p /etc/systemd/system/ecs.service.d
cat >/etc/systemd/system/ecs.service.d/override.conf <<'OVR'
[Unit]
Wants=network-online.target
After=network-online.target docker.service containerd.service

[Service]
Restart=always
RestartSec=5s
OVR
systemctl daemon-reload || true

# 일회성 캐시 정리
if [ ! -f /var/lib/ecs/firstboot.done ]; then
  echo "First boot detected, clearing ECS agent cache..."
  systemctl stop ecs || true
  rm -rf /var/lib/ecs/data/* || true
  touch /var/lib/ecs/firstboot.done
fi

# 에이전트 시작 + 51678 메타데이터 대기 (36회=3분)
echo "Starting ECS agent..."
systemctl enable ecs || true
systemctl start  ecs || true

echo "Waiting for ECS agent metadata endpoint..."
for i in $(seq 1 36); do
  if curl -fs http://localhost:51678/v1/metadata >/dev/null; then
    echo "[OK] ECS agent metadata endpoint is responding."
    break
  fi
  echo "[INFO] ecs-agent not ready yet; retry $i/36"
  systemctl restart ecs || true
  sleep 5
done

# 디버깅 로그
echo "=== Final ECS Status ==="
systemctl status ecs -l || true
echo "=== ECS Agent Logs ==="
journalctl -u ecs -n 200 --no-pager || true
echo "=== user-data end $(date -Is) ==="