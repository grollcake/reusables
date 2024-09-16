#!/usr/bin/sh

if [ "$(id -u)" -eq 0 ]; then
    echo "이 스크립트는 sudo 권한 없이 실행해야 합니다."
    exit 1
fi

# 사용자 이름 입력 받기
read -p "code-server에서 사용할 비밀번호를 입력하세요: " password

# 비밀번호가 비어있는지 확인
if [ -z "$password" ]; then
    echo "패스워드가 비어 있습니다."
    exit 1
fi

curl -fsSL https://code-server.dev/install.sh | sh
sudo systemctl enable --now code-server@$USER
sed -i "s/^bind-addr: .*/bind-addr: 0.0.0.0:8080/" ~/.config/code-server/config.yaml
sed -i "s/^password: .*/password: $password/" ~/.config/code-server/config.yaml
sudo systemctl restart code-server@$USER.service
systemctl status code-server@$USER.service

PUBLICIP=$(curl -s ifconfig.me)
echo "code-server를 설치했습니다. http://$PUBLICIP:8080으로 접속하세요"
