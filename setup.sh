#!/bin/bash

# Move to script location
# parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
parent_path="$( cd -- "$( dirname -- "$0" )" &> /dev/null && pwd )"
echo "parent path is ${parent_path}"
cd ~

# Delete any existing .bashrc and symlink to ours 
BASH_FILE=~/.bashrc_system
if [ -f "$BASH_FILE" ]; then
    echo "~/.bashrc_system already exists."
else 
    echo "Copying ~/.bashrc -> ~/.bashrc_system"
    mv ~/.bashrc ~/.bashrc_system
    ln -s "${parent_path}/.bashrc" ~/.bashrc
fi

# Ditto for vimrc
VIM_FILE=~/.vimrc
if [ -f "$VIM_FILE" ]; then
    echo "Removing old vimrc"
    rm ~/.vimrc
fi

ln -s "${parent_path}/.vimrc" ~/.vimrc

# Same for .tmux.conf
TMUX_FILE=~/.tmux.conf
if [ -f "$TMUX_FILE" ]; then
    echo "Removing old tmux config file"
    rm ~/.tmux.conf
fi

ln -s "${parent_path}/.tmux.conf" ~/.tmux.conf

# inputrc
TMUX_FILE=~/.inputrc
if [ -f "$TMUX_FILE" ]; then
    echo "Removing old tmux config file"
    rm ~/.inputrc
fi

ln -s "${parent_path}/.inputrc" ~/.inputrc

# Set up convenience symlink to aircam
ln -s /home/skydio/aircam ~/aircam


####################################################################################################
# 1Password stuff
####################################################################################################
# if ! command -v jq &> /dev/null; then
#     echo "Installing JQ"
#     sudo apt-get install jq
# fi
# 
# # How to get their latest CLI?
# if ! command -v op &> /dev/null; then
#     echo "Installing 1password"
#     cli_vers="v1.12.3"
#     cli_plat="amd64"
#     cli_path="op_linux_${cli_plat}_${cli_vers}" 
#     cli_archive="${cli_path}.zip"
#     cli_url="https://cache.agilebits.com/dist/1P/op/pkg/${cli_vers}/${cli_archive}"
#     
#     rm $cli_archive
#     rm -rf $cli_path
#     mkdir ${cli_path}
# 
#     echo "Downloading: ${cli_url}" 
#     curl "$cli_url" -o "$cli_archive"
#     file-roller --extract-to=${cli_path} ${cli_archive}
# 
#     sudo mv "${cli_path}/op" "/usr/local/bin/"
# fi
# 
# source ~/.bashrc
# 
# # Force first time signin
# op signin skydio.1password.com jerry.feng@skydio.com

####################################################################################################
# Set up more env stuff
####################################################################################################
# Let's do all of this work in downloads
cd ~/Downloads

# Install rg
curl -LO https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep_13.0.0_amd64.deb
sudo dpkg -i ripgrep_13.0.0_amd64.deb

# Install FZF
sudo apt-get install fzf

# Install powerline
sudo apt-get install powerline

####################################################################################################
# Re-install vim 9.1 with python 3
####################################################################################################
# Prereqs
sudo apt install libncurses5-dev libgtk2.0-dev libatk1.0-dev \
libcairo2-dev libx11-dev libxpm-dev libxt-dev python2-dev \
python3-dev ruby-dev lua5.2 liblua5.2-dev libperl-dev git

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

cd ~/vim
sudo make install

# Set default editor
sudo update-alternatives --install /usr/bin/editor editor /usr/local/bin/vim 1
sudo update-alternatives --set editor /usr/local/bin/vim
sudo update-alternatives --install /usr/bin/vi vi /usr/local/bin/vim 1
sudo update-alternatives --set vi /usr/local/bin/vim

# Refresh
source ~/.bashrc

####################################################################################################
# Install Vundle, install plugins
####################################################################################################
# Clone vundle into vim bundles
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# Call :PluginInstall from command line, then exit
vim -c 'PluginInstall' -c 'qa!'

####################################################################################################
# Finish installing YCM
####################################################################################################
# # Old Bionic installation steps
# cd ~/Downloads
# libclang_archive_name="libclang-10.0.0-x86_64-unknown-linux-gnu.tar.bz2"
# libclang_target_dir="~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp/../clang_archives/"
# libclang_src_path="${parent_path}/resources/${libclang_archive_name}"
# libclang_dst_path="$libclang_target_dir$libclang_archive_name"
#
# cd ~/.vim/bundle/YouCompleteMe
#
# # Checkout old version that is verified to work with our c++ compiler
#
# # NOTE: needed to do this or else submodule update fails
# git config --global url."https://".insteadOf git://
#
# git checkout 9309f77732bde34b7ecf9c2e154b9fcdf14c5295
# git submodule update --init --recursive
#
# # Download the libclang file I've attached above, then move it into YCM. Be aware that your paths
# # may be different from mine
# cp "$libclang_src_path" "$libclang_dst_path"
#
# python3.8 install.py --clang-completer

# Seems like we need this to avoid nexus issues?
# https://skydio.slack.com/archives/C0FRG352B/p1704400919790879?thread_ts=1704400558.799539&cid=C0FRG352B
sudo apt autoremove --purge apt-file

# Prereqs
sudo apt install build-essential cmake python3-dev
apt install mono-complete golang nodejs openjdk-17-jdk openjdk-17-jre npm

# Had to upgrade go
# TODO: Replace with script dir
go_tar_path="${parent_path}/resources/go1.23.4.linux-amd64.tar.gz"
sudo rm -rf /usr/bin/go && sudo tar -C /usr/local -xzf "$go_tar_path" 
export PATH=$PATH:/usr/local/go/bin
source ~/.bashrc

go version

# Build YCM
cd ~/.vim/bundle/YouCompleteMe

# Had to modify ~/.vim/bundle/YouCompleteMe/third_party/ycmd/build.py
# Replace smth BooleanArgument with "store_true"
sed -i "s/argparse.BooleanOptionalArgument/'store_true'/1" third_party/ycmd/build.py

python3 install.py --all --verbose

# Refresh
source ~/.bashrc

# Verify 
echo "Verifying vim installation..."
vim_version=$(vim --version)

if grep -q 'python3.8' <<< "$vim_version"; then
	echo "Vim has python 3.8"
fi


