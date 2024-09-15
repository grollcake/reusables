# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

############################################################################
# 여기부터는 별도로 추가한 옵션입니다.
############################################################################
create-user() {
    # sudo 권한 확인
    if ! sudo -n true 2>/dev/null; then
        echo "이 함수는 sudo 권한이 필요합니다. sudo 권한이 있는지 확인하세요."
        return 1
    fi

    # 사용자 이름 입력 받기
    read -p "새 사용자 이름을 입력하세요: " username

    # 사용자 이름이 비어있는지 확인
    if [[ -z "$username" ]]; then
        echo "사용자 이름이 비어 있습니다."
        return 1
    fi

    # 패스워드 입력 받기 (입력 시 화면에 표시되지 않음)
    read -s -p "패스워드를 입력하세요: " password
    echo
    read -s -p "패스워드를 다시 입력하세요: " password_confirm
    echo

    # 패스워드 일치 여부 확인
    if [[ "$password" != "$password_confirm" ]]; then
        echo "패스워드가 일치하지 않습니다."
        return 1
    fi

    # 사용자 생성 (비대화식으로)
    sudo adduser --disabled-password --gecos "" "$username"
    if [[ $? -ne 0 ]]; then
        echo "사용자 생성에 실패했습니다."
        return 1
    fi

    # 패스워드 설정
    echo "$username:$password" | sudo chpasswd
    if [[ $? -ne 0 ]]; then
        echo "패스워드 설정에 실패했습니다."
        return 1
    fi

    # sudoers 파일에 패스워드 없이 sudo 권한 부여
    sudo bash -c "echo '$username ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/$username"
    if [[ $? -ne 0 ]]; then
        echo "sudoers 파일 설정에 실패했습니다."
        return 1
    fi

    # sudoers 파일 권한 설정
    sudo chmod 0440 /etc/sudoers.d/"$username"
    if [[ $? -ne 0 ]]; then
        echo "sudoers 파일 권한 설정에 실패했습니다."
        return 1
    fi

    echo "사용자 '$username'이(가) 성공적으로 생성되었으며, 패스워드 없이 sudo 권한이 부여되었습니다."
}

# tabby에서 sftp 기능 이용 시 현재 디랙토리를 인식하도록 하는 설정
export PS1="$PS1\[\e]1337;CurrentDir="'$(pwd)\a\]'
