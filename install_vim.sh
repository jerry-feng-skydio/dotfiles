#!/usr/bin/env bash

sudo apt install libncurses5-dev libgtk2.0-dev libatk1.0-dev libcairo2-dev libx11-dev libxpm-dev libxt-dev python2-dev python3-dev ruby-dev lua5.2 liblua5.2-dev libperl-dev git

# Uninstall existing vim
sudo apt remove vim vim-runtime gvim

# Build from source
cd ~
git clone https://github.com/vim/vim.git
cd vim
./configure --with-features=huge \
            --enable-multibyte \
            --enable-rubyinterp=yes \
            --enable-python3interp=yes \
            --with-python3-config-dir=$(python3-config --configdir) \
            --enable-perlinterp=yes \
            --enable-luainterp=yes \
            --enable-gui=gtk2 \
            --enable-cscope \
            --prefix=/usr/local

make VIMRUNTIMEDIR=/usr/local/share/vim/vim91

sudo apt install checkinstall
cd ~/vim
sudo checkinstall

# Set default editor
sudo update-alternatives --install /usr/bin/editor editor /usr/local/bin/vim 1
sudo update-alternatives --set editor /usr/local/bin/vim
sudo update-alternatives --install /usr/bin/vi vi /usr/local/bin/vim 1
sudo update-alternatives --set vi /usr/local/bin/vim

#################### Plugin block here
# Seems like we need this to avoid nexus issues?
# https://skydio.slack.com/archives/C0FRG352B/p1704400919790879?thread_ts=1704400558.799539&cid=C0FRG352B
sudo apt autoremove --purge apt-file

# Prereqs
sudo apt install build-essential cmake python3-dev
apt install mono-complete golang nodejs openjdk-17-jdk openjdk-17-jre npm

# Had to modify ~/.vim/bundle/YouCompleteMe/third_party/ycmd/build.py
# Replace smth BooleanArgument with "store_true"
sed -i "s/argparse.BooleanOptionalAction/'store_true'/1" third_party/ycmd/build.py

# Had to upgrade go
# TODO: Replace with script dir
sudo rm -rf /usr/bin/go && sudo tar -C /usr/local -xzf ~/dotfiles/resources/go1.23.4.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
source ~/.bashrc

go version

# Build YCM
cd ~/.vim/bundle/YouCompleteMe
python3 install.py --all --verbose
