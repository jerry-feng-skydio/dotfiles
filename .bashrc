source /etc/skel/.bashrc

# Don't know why this isn't in the skel bashrc...
alias yubact="ssh-add -D && ssh-add -e /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so; ssh-add -s /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so"
if [ -f /usr/local/bin/ssh-find-agent.sh ]; then
    . /usr/local/bin/ssh-find-agent.sh
    ssh_find_agent -a
fi

# Git branch in prompt.

parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# Hostname-based prompt color
case "$(hostname)" in
  *home*)
    # Blue cwd, green git branch
    export PS1="\u@\h \[\033[1;34m\]\W\[\033[32m\]\$(parse_git_branch)\[\033[00m\] $ "
    ;;
  *work*|*skydio*|*corp*)
    # Yellow cwd, cyan git branch
    export PS1="\u@\h \[\033[1;33m\]\W\[\033[36m\]\$(parse_git_branch)\[\033[00m\] $ "
    ;;
  *)
    # Magenta cwd, green git branch
    export PS1="\u@\h \[\033[1;35m\]\W\[\033[32m\]\$(parse_git_branch)\[\033[00m\] $ "
    ;;
esac

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

# Add android platform tools to path
export PATH=~/Android/Sdk/platform-tools:${PATH}

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
    ~/.dotfiles/skymux.sh
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

blt() {
    ssh qcu -t "bot-lcm-tunnel &"
    ./skyrun bin bot-lcm-tunnel 192.168.11.1
}


fpl() {
  local host="c38"
  local needle="$1"

  if [[ -z "$needle" ]]; then
    echo "Usage: find_process_logs <process_name>" >&2
    return 1
  fi

  ssh -t "$host" 'bash -s' -- "$needle" <<'EOF'
set -euo pipefail

needle="$1"

pids=$(
  top -b -n 1 |
    awk -v needle="$needle" '
      $1 ~ /^[0-9]+$/ {
        cmd = ""
        for (i = 12; i <= NF; i++) {
          cmd = cmd (i == 12 ? "" : " ") $i
        }

        if (index(cmd, needle) &&
            cmd !~ /^grep / &&
            cmd !~ /^awk / &&
            cmd !~ /^bash -s /) {
          print $1
        }
      }
    '
)

if [[ -z "$pids" ]]; then
  echo "No matching processes found for: $needle" >&2
  exit 1
fi

pid_regex=$(echo "$pids" | paste -sd'|' -)

echo "Matching PIDs: $(echo "$pids" | paste -sd',' -)" >&2

logcat -v threadtime | awk -v pids="$pid_regex" '
  $3 ~ "^(" pids ")$" { print }
'
EOF
}


alias certc18='bazel run //tools/cloud_api/client_utils:create_certificate -- cert $(curl -s 192.168.20.1:80/hostname)'
alias studio="~/android-studio/bin/studio.sh"
alias adb_wifi='bazel run //tools/dev_tools:c18_adb_phone -- wifi'
alias fast_android_build="~/.dotfiles/fast_android_build.sh"
alias skymux="~/.dotfiles/skymux.sh"
alias skyvpn="~/.dotfiles/skyvpn.sh"
alias watch_flight_deck="~/.dotfiles/watch_vehicle_flight_deck.sh"
alias grep_flight_deck="~/.dotfiles/grep_flight_deck.sh"
alias lazy_ota="~/.dotfiles/lazy_ota.sh"
alias jerry_first_time_setup="~/.dotfiles/setup.sh"
alias oopsies='git add . && git commit --amend --no-edit && git push --force'
alias order='python3 ~/.dotfiles/ordered_grep.py'
alias decrypt="./skyrun bin decrypt_debug_logs_tar"

alias gdf='cd ~/.dotfiles'
alias gac='cd ~/aircam'

alias glp="git log --pretty=oneline"

alias gle="git log --oneline"
alias revupl="./skyrun bin revup upload"
alias revupa="./skyrun bin revup amend"
alias revupr="./skyrun bin revup restack"


alias coder="ssh main.jfeng-claude.jerry-feng.coder"
alias coder_aosp="ssh main.jfeng-aosp.jerry-feng.coder"
alias jroot="cd ~/.dotfiles"
alias gitjf="git -C ~/.dotfiles/"
alias vimjf="vim ~/.dotfiles"
alias brc="vim ~/.dotfiles/.bashrc"
alias vrc="vim ~/.dotfiles/.vimrc"
alias src="source ~/.dotfiles/.bashrc"

export EDITOR=vim
export AIRCAM_WEBRTC_NETWORK_INTERFACE_NAME="enp6s0"
export CLOUD_CLIENT_EMAIL="jerry.feng@skydio.com"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
export AWS_PROFILE=default

export PATH=/home/skydio/software/android-sdk-skydio-v2/platform-tools:$PATH
export PATH=$HOME/.local/bin:$PATH
