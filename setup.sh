#!/bin/bash
set -euo pipefail

# Log everything for debugging on ephemeral machines
SETUP_LOG="/tmp/setup-$(date +%s).log"
exec > >(tee -a "$SETUP_LOG") 2>&1
echo "Setup log: $SETUP_LOG"

####################################################################################################
# Parse flags
####################################################################################################
soft_reset=false

while getopts ":hs" opt; do
  case ${opt} in
    h )
      echo "Usage: $0 [-h] [-s]"
      echo "  -s  Soft reset: only re-link dotfiles, skip installs"
      exit 0
      ;;
    s )
      soft_reset=true
      ;;
    \? )
      echo "Invalid option: -$OPTARG" 1>&2
      exit 1
      ;;
  esac
done

####################################################################################################
# Resolve script directory
####################################################################################################
PARENT_PATH="$( cd -- "$( dirname -- "$0" )" &> /dev/null && pwd )"
echo "Dotfiles path: ${PARENT_PATH}"
echo "System:  $(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"' || uname -a)"
echo "Python:  $(python3 --version 2>&1)"
echo "GCC:     $(gcc --version 2>/dev/null | head -1 || echo 'not found')"

####################################################################################################
# Initialize submodules (e.g. SkyRG vim plugin)
# Always pulls the latest commit from the tracked branch (set in .gitmodules).
# To pin a specific commit instead (e.g. for a shared workstation):
#   git submodule update --init --recursive   # (without --remote)
#   cd skyrg-plugin && git checkout <commit> && cd .. && git add skyrg-plugin
####################################################################################################
cd "$PARENT_PATH"
git submodule update --init --remote --recursive

####################################################################################################
# Cache the default bashrc before overwriting
####################################################################################################
BASH_FILE=~/.bashrc_system_default
if [ -f "$BASH_FILE" ]; then
    echo "${BASH_FILE} already exists."
elif [ -f ~/.bashrc ]; then
    echo "Copying ~/.bashrc -> ${BASH_FILE}"
    cp ~/.bashrc "$BASH_FILE"
fi

####################################################################################################
# Symlink dotfiles
####################################################################################################
reset_link() {
    local name=$1
    local dotfiles_path="${PARENT_PATH}/$name"
    local home_path="${HOME}/$name"
    echo "Linking $dotfiles_path -> $home_path"
    ln -sf "$dotfiles_path" "$home_path"
}

reset_link ".bashrc"
reset_link ".vimrc"
reset_link ".tmux.conf"
reset_link ".inputrc"
reset_link ".gitconfig"

# Windsurf (IDE) agent rules
mkdir -p ~/.windsurf
ln -sfn "${PARENT_PATH}/windsurf-rules" ~/.windsurf/rules

# Set up convenience symlink to aircam (only if the target exists)
if [ -d /home/skydio/aircam ]; then
    ln -sfn /home/skydio/aircam ~/aircam
fi

####################################################################################################
# Link AI agent context into work repos
####################################################################################################
if [ -f "${PARENT_PATH}/plans/setup.sh" ]; then
  echo "Linking agent context files..."
  bash "${PARENT_PATH}/plans/setup.sh"
fi

if [ "$soft_reset" = "true" ]; then
    echo "Soft reset complete — dotfiles re-linked."
    exit 0
fi

####################################################################################################
# Update package lists
####################################################################################################
sudo apt-get update -y

####################################################################################################
# Install CLI tools
####################################################################################################
# Install rg
if ! command -v rg &> /dev/null; then
    echo "Installing ripgrep..."
    curl -fLo /tmp/ripgrep.deb \
        https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep_13.0.0_amd64.deb
    sudo dpkg -i /tmp/ripgrep.deb
    rm -f /tmp/ripgrep.deb
fi

# Install FZF
sudo apt-get install -y fzf

# Install powerline
sudo apt-get install -y powerline

####################################################################################################
# Re-install vim with python 3
####################################################################################################
# Auto-detect the latest stable Vim 9.1.x tag, fall back to a known-good version.
# Any v9.1.x compiles fine on Ubuntu 18.04+ (GCC 7+, Python 3.6+, CMake 3.10+).
VIM_TAG_FALLBACK="v9.1.1000"
if VIM_TAG=$(timeout 10 git ls-remote --tags https://github.com/vim/vim.git 'refs/tags/v9.1.*' 2>/dev/null \
    | sed 's|.*refs/tags/||' | grep -v '\^{}' | sort -V | tail -1) && [ -n "$VIM_TAG" ]; then
    echo "Latest Vim tag: $VIM_TAG"
else
    VIM_TAG="$VIM_TAG_FALLBACK"
    echo "Could not fetch tags, using fallback: $VIM_TAG"
fi
VIM_DESIRED_PATCH=$(echo "$VIM_TAG" | grep -oP '[0-9]+$' || echo "1000")

need_vim_build=true
if command -v vim &>/dev/null && vim --version | grep -q '+python3'; then
    vim_patch=$(vim --version | grep -oP 'Included patches: 1-\K[0-9]+' || echo "0")
    if [ "${vim_patch:-0}" -ge "$VIM_DESIRED_PATCH" ] 2>/dev/null; then
        need_vim_build=false
        echo "Vim 9.1.${vim_patch} with +python3 already installed, skipping build."
    fi
fi

if [ "$need_vim_build" = true ]; then
    # Prereqs
    sudo apt-get install -y libncurses5-dev libgtk2.0-dev libatk1.0-dev \
        libcairo2-dev libx11-dev libxpm-dev libxt-dev \
        python3-dev ruby-dev lua5.2 liblua5.2-dev libperl-dev git
    # python2-dev is unavailable on Ubuntu 22.04+; optional for vim
    sudo apt-get install -y python2-dev 2>/dev/null || true

    # Uninstall existing vim
    sudo apt-get remove -y vim vim-runtime gvim || true

    # Build from source — pin to a tag for reproducibility
    if [ -d ~/vim ]; then
        echo "~/vim already exists, fetching ${VIM_TAG}..."
        cd ~/vim && git fetch --depth 1 origin tag "$VIM_TAG" --no-tags
    else
        git clone --depth 1 --branch "$VIM_TAG" https://github.com/vim/vim.git ~/vim
    fi
    cd ~/vim
    git checkout "$VIM_TAG"

    ./configure --with-features=huge \
                --enable-multibyte \
                --enable-rubyinterp=yes \
                --enable-python3interp=yes \
                --with-python3-config-dir="$(python3-config --configdir)" \
                --enable-perlinterp=yes \
                --enable-luainterp=yes \
                --enable-gui=gtk2 \
                --enable-cscope \
                --prefix=/usr/local

    # Derive runtime dir from the tag (v9.1.x → vim91)
    VIM_VER="vim$(echo "$VIM_TAG" | grep -oP '[0-9]+\.[0-9]+' | tr -d '.')"
    make VIMRUNTIMEDIR="/usr/local/share/vim/${VIM_VER}"

    sudo make install

    # Set default editor
    sudo update-alternatives --install /usr/bin/editor editor /usr/local/bin/vim 1
    sudo update-alternatives --set editor /usr/local/bin/vim
    sudo update-alternatives --install /usr/bin/vi vi /usr/local/bin/vim 1
    sudo update-alternatives --set vi /usr/local/bin/vim
fi

####################################################################################################
# Install Vundle, install plugins
####################################################################################################
if [ ! -d ~/.vim/bundle/Vundle.vim ]; then
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi

# Ensure undo dir exists for vimrc's undofile setting
mkdir -p ~/.vim/undodir

# Call :PluginInstall from command line, then exit
vim -c 'PluginInstall' -c 'qa!'

####################################################################################################
# Ensure coc.nvim is on the 'release' branch (ships pre-built build/index.js).
# Vundle doesn't reliably honor {'branch': 'release'}, so we force it here.
####################################################################################################
if [ -d ~/.vim/bundle/coc.nvim ] && [ ! -f ~/.vim/bundle/coc.nvim/build/index.js ]; then
    echo "Switching coc.nvim to release branch (pre-built)..."
    cd ~/.vim/bundle/coc.nvim
    git fetch origin release --depth 1
    git checkout -B release origin/release
fi

####################################################################################################
# Finish installing YCM
####################################################################################################
need_ycm_build=true
if compgen -G "$HOME/.vim/bundle/YouCompleteMe/third_party/ycmd/ycm_core*" > /dev/null 2>&1; then
    echo "YCM already built, skipping."
    need_ycm_build=false
fi

if [ "$need_ycm_build" = true ]; then
    # Seems like we need this to avoid nexus issues?
    # https://skydio.slack.com/archives/C0FRG352B/p1704400919790879?thread_ts=1704400558.799539&cid=C0FRG352B
    sudo apt-get autoremove -y --purge apt-file || true

    # Prereqs
    sudo apt-get install -y build-essential cmake python3-dev
    sudo apt-get install -y mono-complete golang nodejs openjdk-17-jdk openjdk-17-jre npm

    # Upgrade go from bundled tarball (only needed for YCM's Go completer)
    DESIRED_GO_VER="1.23.4"
    current_go_ver=$(go version 2>/dev/null | grep -oP '[0-9]+\.[0-9]+\.[0-9]+' || echo "none")
    if [ "$current_go_ver" != "$DESIRED_GO_VER" ]; then
        go_tar_path="${PARENT_PATH}/resources/go${DESIRED_GO_VER}.linux-amd64.tar.gz"
        if [ -f "$go_tar_path" ]; then
            sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf "$go_tar_path"
            export PATH=/usr/local/go/bin:$PATH
            go version
        else
            echo "WARNING: Go tarball not found at $go_tar_path, skipping Go upgrade"
        fi
    else
        echo "Go ${DESIRED_GO_VER} already installed, skipping upgrade."
    fi

    # Build YCM
    cd ~/.vim/bundle/YouCompleteMe

    # Had to modify ~/.vim/bundle/YouCompleteMe/third_party/ycmd/build.py
    # Replace BooleanOptionalAction with "store_true" for older python compat
    sed -i "s/argparse.BooleanOptionalAction/'store_true'/g" third_party/ycmd/build.py

    python3 install.py --all --verbose
fi

####################################################################################################
# Verify
####################################################################################################
echo ""
echo "========================================"
echo "Verifying vim installation..."
vim_version=$(vim --version | head -2)
echo "$vim_version"

if vim --version | grep -q '+python3'; then
    echo "OK: Vim has python3 support"
else
    echo "WARNING: Vim does NOT have python3 support"
fi

echo ""
echo "Setup complete. Log saved to: $SETUP_LOG"
echo "Run 'source ~/.bashrc' in your shell to pick up changes."
