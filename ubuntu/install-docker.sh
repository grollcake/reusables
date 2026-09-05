#!/bin/bash
set -e

curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker "$USER"

echo "Docker 설치 완료. SSH에 재접속한 뒤 사용하세요."
