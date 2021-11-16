#!/bin/bash

# Move to script location
# parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
parent_path="$( cd -- "$( dirname -- "$0" )" &> /dev/null && pwd )"
echo "parent path is ${parent_path}"
cd ~

# Delete any existing .bashrc and symlink to ours 
rm ~/.bashrc
ln -s "${parent_path}/.bashrc" "~/.bashrc"

# Ditto for vimrc
rm ~/.vimrc
ln -s "${parent_path}/.vimrc" "~/.vimrc"

####################################################################################################
# 1Password stuff
####################################################################################################
if ! command -v jq &> /dev/null; then
    echo "Installing JQ"
    sudo apt-get install jq
fi

# How to get their latest CLI?
if ! command -v op &> /dev/null; then
    echo "Installing 1password"
    cli_vers="v1.12.3"
    cli_plat="amd64"
    cli_path="op_linux_${cli_plat}_${cli_vers}" 
    cli_archive="${cli_path}.zip"
    cli_url="https://cache.agilebits.com/dist/1P/op/pkg/${cli_vers}/${cli_archive}"
    
    rm $cli_archive
    rm -rf $cli_path
    mkdir ${cli_path}

    echo "Downloading: ${cli_url}" 
    curl "$cli_url" -o "$cli_archive"
    file-roller --extract-to=${cli_path} ${cli_archive}

    sudo mv "${cli_path}/op" "/usr/local/bin/"
fi

source ~/.bashrc

# Force first time signin
op signin skydio.1password.com jerry.feng@skydio.com

####################################################################################################
# Set up more env stuff
####################################################################################################
# Let's do all of this work in downloads
cd ~/Downloads

# Install rg
curl -LO https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep_13.0.0_amd64.deb
sudo dpkg -i ripgrep_13.0.0_amd64.deb

# Install FZF?

####################################################################################################
# Re-install vim with python 3.8:
####################################################################################################
# Uninstall pre-existing versions of vim:
sudo apt remove vim vim-runtime gvim

# Clone vim and build from source
# Note that we specify that the python3 command must be 'python3.8`
cd ~
git clone https://github.com/vim/vim.git 
cd vim
./configure --with-features=huge \
            --enable-multibyte \
            --enable-rubyinterp=yes \
            --enable-python3interp=yes \
            --with-python3-config-dir=$(python3.8-config --configdir) \
            --with-python3-command=python3.8 \
            --enable-perlinterp=yes \
            --enable-luainterp=yes \
            --enable-gui=gtk2 \
            --enable-cscope \
            --prefix=/usr/local

make VIMRUNTIMEDIR=/usr/local/share/vim/vim82

# Install vim
sudo make install

# Set vim as default editor (updating vi is optional)
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
libclang_archive_name="libclang-10.0.0-x86_64-unknown-linux-gnu.tar.bz2"
libclang_target_dir="~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp/../clang_archives/"
libclang_src_path="${parent_path}/resources/${libclang_archive_name}"
libclang_dst_path="$libclang_target_dir$libclang_archive_name"

cd ~/.vim/bundle/YouCompleteMe

# Checkout old version that is verified to work with our c++ compiler
git checkout 9309f77732bde34b7ecf9c2e154b9fcdf14c5295
git submodule update --init --recursive

# Download the libclang file I've attached above, then move it into YCM. Be aware that your paths
# may be different from mine
cp "$libclang_src_path" "$libclang_dst_path"

python3.8 install.py --clang-completer

# Refresh
source ~/.bashrc

####################################################################################################
# Verify 
####################################################################################################
echo "Verifying vim installation..."
vim_version=$(vim --version)

if grep -q 'python3.8' <<< "$vim_version"; then
    echo "Vim has python 3.8"
fi


