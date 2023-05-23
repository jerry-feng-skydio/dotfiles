source /etc/skel/.bashrc

# Don't know why this isn't in the skel bashrc...
alias yubact="ssh-add -D && ssh-add -e /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so; ssh-add -s /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so"
. /usr/local/bin/ssh-find-agent.sh
ssh_find_agent -a

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

# Powerline configuration
if [ -f /usr/share/powerline/bindings/bash/powerline.sh ]; then
  powerline-daemon -q
  POWERLINE_BASH_CONTINUATION=1
  POWERLINE_BASH_SELECT=1
  source /usr/share/powerline/bindings/bash/powerline.sh
fi

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

# This sets aircam root and adds the aircam binaries path to our path.
# We don't want to generically do this because it doesn't work with multiple aircams
set_aircam_root() {
    echo "Setting AIRCAM_ROOT to $(pwd)"
    export AIRCAM_ROOT="$(pwd)"
    export PATH=${AIRCAM_ROOT}/build/host_aircam/bin:${PATH}
    export PATH=${AIRCAM_ROOT}/build/host_third_party/bin:${PATH}
    echo $PATH
}

deploy_r47() {
    ssh qcu -t "sudo rm -rf /home/skydio/bazel/aircam.runfiles/aircam/launch/vehicle_deploy/opencl_kernels/*"
    ./skyrun bazel bazel_deploy --ignore_flashpack_version
}


alias adb_over_wifi="~/.dotfiles/./adb_over_wifi.sh"
alias fast_android_build="~/.dotfiles/./fast_android_build.sh"
alias skymux="~/.dotfiles/./skymux.sh"
alias skyvpn="~/.dotfiles/./skyvpn.sh"
alias watch_flight_deck="~/.dotfiles/./watch_vehicle_flight_deck.sh"
alias grep_flight_deck="~/.dotfiles/grep_flight_deck.sh"
alias lazy_ota="~/.dotfiles/lazy_ota.sh"
alias jerry_first_time_setup="~/.dotfiles/setup.sh"

export EDITOR=vim
export AIRCAM_WEBRTC_NETWORK_INTERFACE_NAME="enp6s0"
export CLOUD_CLIENT_EMAIL="jerry.feng@skydio.com"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
