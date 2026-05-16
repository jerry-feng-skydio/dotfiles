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

####################################################################################################
# Initialize submodules (e.g. SkyRG vim plugin)
####################################################################################################
cd "$PARENT_PATH"
git submodule update --init --recursive

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

# Set up convenience symlink to aircam (only if the target exists)
if [ -d /home/skydio/aircam ]; then
    ln -sf /home/skydio/aircam ~/aircam
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
# Prereqs
sudo apt-get install -y libncurses5-dev libgtk2.0-dev libatk1.0-dev \
    libcairo2-dev libx11-dev libxpm-dev libxt-dev python2-dev \
    python3-dev ruby-dev lua5.2 liblua5.2-dev libperl-dev git

# Uninstall existing vim
sudo apt-get remove -y vim vim-runtime gvim || true

# Build from source — pin to a tag for reproducibility
VIM_TAG="v9.1.0"
if [ -d ~/vim ]; then
    echo "~/vim already exists, pulling latest for ${VIM_TAG}..."
    cd ~/vim && git fetch --tags
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

# Derive runtime dir from the version instead of hardcoding
VIM_VER=$(sed -n 's/.*VIM_VERSION_NODOT\s*=\s*\(vim[0-9]*\).*/\1/p' Makefile || echo "vim91")
make VIMRUNTIMEDIR="/usr/local/share/vim/${VIM_VER}"

sudo make install

# Set default editor
sudo update-alternatives --install /usr/bin/editor editor /usr/local/bin/vim 1
sudo update-alternatives --set editor /usr/local/bin/vim
sudo update-alternatives --install /usr/bin/vi vi /usr/local/bin/vim 1
sudo update-alternatives --set vi /usr/local/bin/vim

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
# Finish installing YCM
####################################################################################################
# Seems like we need this to avoid nexus issues?
# https://skydio.slack.com/archives/C0FRG352B/p1704400919790879?thread_ts=1704400558.799539&cid=C0FRG352B
sudo apt-get autoremove -y --purge apt-file || true

# Prereqs
sudo apt-get install -y build-essential cmake python3-dev
sudo apt-get install -y mono-complete golang nodejs openjdk-17-jdk openjdk-17-jre npm

# Upgrade go from bundled tarball
go_tar_path="${PARENT_PATH}/resources/go1.23.4.linux-amd64.tar.gz"
if [ -f "$go_tar_path" ]; then
    sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf "$go_tar_path"
    export PATH=/usr/local/go/bin:$PATH
    go version
else
    echo "WARNING: Go tarball not found at $go_tar_path, skipping Go upgrade"
fi

# Build YCM
cd ~/.vim/bundle/YouCompleteMe

# Had to modify ~/.vim/bundle/YouCompleteMe/third_party/ycmd/build.py
# Replace BooleanOptionalAction with "store_true" for older python compat
sed -i "s/argparse.BooleanOptionalAction/'store_true'/g" third_party/ycmd/build.py

python3 install.py --all --verbose

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
