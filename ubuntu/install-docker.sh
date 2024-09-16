#!/bin/bash

# sudo 권한 확인
if ! sudo -n true 2>/dev/null; then
    echo "실행하려면 sudo 권한이 필요합니다. sudo 권한이 있는지 확인하세요."
    return 1
fi

sudo apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker $USER

echo "docker 설치를 완료했습니다. ssh 터미널을 재기동하세요"
