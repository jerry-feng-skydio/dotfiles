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
# case "$TERM" in
    # xterm-color|*-256color) color_prompt=yes;;
# esac
export TERM=xterm-256color

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
# BEGIN ANSIBLE MANAGED BLOCK
HISTSIZE=100000
HISTFILESIZE=200000

export PROMPT_COMMAND='history -a'
export PYTHONDONTWRITEBYTECODE=1
export AIRCAM_ROOT=/home/skydio/aircam
export PATH=${AIRCAM_ROOT}/build/host_third_party/bin:${PATH}
export PATH=${AIRCAM_ROOT}/build/host_aircam/bin:${PATH}

eval "$(register-python-argcomplete launch_pipeline)"
eval "$(register-python-argcomplete skyrun)"
# END ANSIBLE MANAGED BLOCK

export SKYREV_REMOTE_USER="jerry.feng"

# Alias for Yubikey pin prompt
alias yubact="ssh-add -D && ssh-add -e /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so; ssh-add -s /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so"


# Auto finds ssh-agent
. ~/yubikey_scripts/ssh-find-agent/ssh-find-agent.sh
ssh_find_agent -a
if [ -z "/run/user/1000/keyring/ssh" ]
then
    eval SSH_AUTH_SOCK=/tmp/ssh-XuTl4nVH8MWX/agent.10905; export SSH_AUTH_SOCK;
SSH_AGENT_PID=10906; export SSH_AGENT_PID;
echo Agent pid 10906; > /dev/null
    ssh-add -l >/dev/null || alias ssh='ssh-add -l >/dev/null || ssh-add && unalias ssh; ssh'
fi

# Git branch in prompt.

parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# export PS1="\u@\h \W\[\033[32m\]\$(parse_git_branch)\[\033[00m\] $ "
export PS1="\u@\h \[\033[1;34m\]\W\[\033[32m\]\$(parse_git_branch)\[\033[00m\] $ "
#export PS1="\u@\h \[\033[1;34m\]\W\[\033[00m\] $ "

# Disallow auto renaming windows
DISABLE_AUTO_TITLE=true

# Ctags generation shortcut
alias ctaggen='ctags -R --exclude=.git --exclude="build/build/*" --exclude="build/clones/*" --exclude="build/deploy/*" --exclude="build/doc/*" --exclude="build/images/*" --exclude="build/install/*" --exclude="build/stamps/*" --exclude="build/web/*" --exclude="build/*.json" --exclude=clion-aircam-make-relwithdebinfo --exclude="third_party*" --exclude="shared/third_party*" --exclude=graveyard --exclude="tools/lcmtype_auto_translation/*"' 

# Quick TMUX editing
edit_tmux() {
    vim ~/.tmux.conf
    tmux source ~/.tmux.conf
}

edit_bashrc() {
    vim ~/.bashrc
    source ~/.bashrc
}

toggle_skymux_git() {
    FILE=~/.iwanttmuxgitstatus
    if test -f "$FILE"; then
        echo "Disabling tmux git statuses"
        rm $FILE
    else
        echo "Enabling tmux git statuses"
        touch $FILE
    fi
}

# Go to /home/skydio/ on session start
#cd /home/skydio/

skymux() {
    ~/.dotfiles/./skymux.sh
}

alias adb_over_wifi="~/.dotfiles/./adb_over_wifi.sh"
alias fast_android_build="~/.dotfiles/./fast_android_build.sh"
alias skymux="~/.dotfiles/./skymux.sh"
alias skyvpn="~/.dotfiles/./skyvpn.sh"
alias watch_flight_deck="~/.dotfiles/./watch_vehicle_flight_deck.sh"

export EDITOR=vim
