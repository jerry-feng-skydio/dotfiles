#!/bin/sh

# Move to script location
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"

# Delete any existing .bashrc and symlink to ours 
rm ~/.bashrc
ln -s .bashrc ~/.bashrc

# Ditto for vimrc
rm ~/.vimrc
ln -s .vimrc ~/.vimrc

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
libclang_src_path="${parent_path}/resources/libclang-10.0.0-x86_64-unknown-linux-gnu.tar.bz2"
libclang_dst_path="~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp/../clang_archives/libclang-10.0.0-x86_64-unknown-linux-gnu.tar.bz2"

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


