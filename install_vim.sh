#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$( cd -- "$( dirname -- "$0" )" &> /dev/null && pwd )"

# Auto-detect the latest stable Vim 9.1.x tag, fall back to a known-good version
VIM_TAG_FALLBACK="v9.1.1000"
if VIM_TAG=$(timeout 10 git ls-remote --tags https://github.com/vim/vim.git 'refs/tags/v9.1.*' 2>/dev/null \
    | sed 's|.*refs/tags/||' | grep -v '\^{}' | sort -V | tail -1) && [ -n "$VIM_TAG" ]; then
    echo "Latest Vim tag: $VIM_TAG"
else
    VIM_TAG="$VIM_TAG_FALLBACK"
    echo "Could not fetch tags, using fallback: $VIM_TAG"
fi
VIM_DESIRED_PATCH=$(echo "$VIM_TAG" | grep -oP '[0-9]+$' || echo "1000")

# Skip build if already at target version with +python3
need_vim_build=true
if command -v vim &>/dev/null && vim --version | grep -q '+python3'; then
    vim_patch=$(vim --version | grep -oP 'Included patches: 1-\K[0-9]+' || echo "0")
    if [ "${vim_patch:-0}" -ge "$VIM_DESIRED_PATCH" ] 2>/dev/null; then
        need_vim_build=false
        echo "Vim 9.1.${vim_patch} with +python3 already installed, skipping build."
    fi
fi

if [ "$need_vim_build" = true ]; then
    sudo apt-get install -y libncurses5-dev libgtk2.0-dev libatk1.0-dev \
        libcairo2-dev libx11-dev libxpm-dev libxt-dev \
        python3-dev ruby-dev lua5.2 liblua5.2-dev libperl-dev git
    # python2-dev is unavailable on Ubuntu 22.04+; optional for vim
    sudo apt-get install -y python2-dev 2>/dev/null || true

    # Uninstall existing vim
    sudo apt-get remove -y vim vim-runtime gvim || true

    # Build from source
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

#################### YCM build
need_ycm_build=true
if compgen -G "$HOME/.vim/bundle/YouCompleteMe/third_party/ycmd/ycm_core*" > /dev/null 2>&1; then
    echo "YCM already built, skipping."
    need_ycm_build=false
fi

if [ "$need_ycm_build" = true ]; then
    # https://skydio.slack.com/archives/C0FRG352B/p1704400919790879?thread_ts=1704400558.799539&cid=C0FRG352B
    sudo apt-get autoremove -y --purge apt-file || true

    # Prereqs
    sudo apt-get install -y build-essential cmake python3-dev
    sudo apt-get install -y mono-complete golang nodejs openjdk-17-jdk openjdk-17-jre npm

    # Upgrade go (only needed for YCM's Go completer)
    DESIRED_GO_VER="1.23.4"
    current_go_ver=$(go version 2>/dev/null | grep -oP '[0-9]+\.[0-9]+\.[0-9]+' || echo "none")
    if [ "$current_go_ver" != "$DESIRED_GO_VER" ]; then
        go_tar_path="${SCRIPT_DIR}/resources/go${DESIRED_GO_VER}.linux-amd64.tar.gz"
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

    # Replace BooleanOptionalAction with "store_true" for Python 3.8 compat
    sed -i "s/argparse.BooleanOptionalAction/'store_true'/g" third_party/ycmd/build.py

    python3 install.py --all --verbose
fi
