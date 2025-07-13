#!/bin/bash

# sudo 권한 확인
if ! sudo -n true 2>/dev/null; then
    echo "실행하려면 sudo 권한이 필요합니다. sudo 권한이 있는지 확인하세요."
    return 1
fi

# zsh 설치
echo "zsh, git, fzf를 설치하는 중..."
sudo apt update
sudo apt install -y zsh git fzf

# 기본 셸을 zsh로 변경
echo "기본 셸을 zsh로 변경하는 중..."
chsh -s $(which zsh)

# oh-my-zsh 설치
echo "oh-my-zsh를 설치하는 중..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# zsh-autosuggestions 플러그인 설치
echo "zsh-autosuggestions 플러그인을 설치하는 중..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# zsh-syntax-highlighting 플러그인 설치
echo "zsh-syntax-highlighting 플러그인을 설치하는 중..."
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# zsh-z 플러그인 설치
echo "zsh-z 플러그인을 설치하는 중..."
git clone https://github.com/agkozak/zsh-z ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-z

# .zshrc 파일에 플러그인 추가
echo "플러그인을 .zshrc에 추가하는 중..."
sed -i '/^plugins=/c\plugins=( git zsh-syntax-highlighting zsh-autosuggestions fzf zsh-z )' ~/.zshrc

echo "zsh와 oh-my-zsh 설치를 완료했습니다. 터미널을 재시작하거나 'zsh' 명령어를 실행하세요."
