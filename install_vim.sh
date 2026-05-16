#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$( cd -- "$( dirname -- "$0" )" &> /dev/null && pwd )"

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

#################### Plugin block here
# Seems like we need this to avoid nexus issues?
# https://skydio.slack.com/archives/C0FRG352B/p1704400919790879?thread_ts=1704400558.799539&cid=C0FRG352B
sudo apt-get autoremove -y --purge apt-file || true

# Prereqs
sudo apt-get install -y build-essential cmake python3-dev
sudo apt-get install -y mono-complete golang nodejs openjdk-17-jdk openjdk-17-jre npm

# Had to upgrade go
go_tar_path="${SCRIPT_DIR}/resources/go1.23.4.linux-amd64.tar.gz"
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
