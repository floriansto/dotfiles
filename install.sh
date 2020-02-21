#!/bin/bash

VERSION="v0.1"
BASE_DIR=$(dirname $0)
cd "${BASE_DIR}"
BASE_DIR="${PWD}"

if [[ $1 == "noconfirm" ]]; then
    NOCONFIRM=1
    INTERACTIVE_LN=""
else
    NOCONFIRM=0
    INTERACTIVE_LN="i"
fi

function log {
    printf '\e[1;33m%*s\e[0m' "$COLUMNS" '' | tr ' ' -
    printf '\r\e[1;33m-- \e[1;32m%s \e[0m\n' "$*"
}

function rsync_os {
    rsync -a $1 $2
}

function install_zsh {
    cd "${HOME}"
    [ ! -d ".oh-my-zsh" ] && git clone --recursive https://github.com/robbyrussell/oh-my-zsh .oh-my-zsh
    cd ".oh-my-zsh"
    [ ! -d "custom/plugins" ] && mkdir -p "custom/plugins"
    cd "custom/plugins"
    [ ! -d "zsh-autosuggestions" ] && git clone https://github.com/zsh-users/zsh-autosuggestions.git
    cd "zsh-autosuggestions"
    git pull
    cd "${HOME}/.oh-my-zsh"
    git pull && git submodule update --init --recursive
    cd "${BASE_DIR}/zsh"
    rsync_os "zshrc" "${HOME}/.zshrc"
    rsync_os "custom/" "${HOME}/.oh-my-zsh/custom"
    backup=""
    [ $OSTYPE != "linux-android" ] && backup="--backup"
    [ -f ~/.envConf ] && [ "`head -n1 ~/.envConf`"="# zsh config file (version: ${VERSION})" ] && source ~/.envConf || mv -vi $backup  ~/.envConf ~/.envConf_`date +%F_%H%M%S`
    #[ -z "$ZSH_THEME" ] && read -p "please enter the zsh theme you wanna use(to use 'mrpi' just hit enter): " ZSH_THEME
    [ -z "$ZSH_THEME" ] && ZSH_THEME="mrpi"

    local ZSH_CUSTOM="${BASE_DIR}/zsh/custom"
    echo "# zsh config file (version: $VERSION)" >~/.envConf
    echo "export ZSH_CUSTOM=\"$ZSH_CUSTOM\"" >>~/.envConf
    echo "export ZSH_THEME=\"$ZSH_THEME\"" >>~/.envConf
    echo "export ZSH_DISABLE_COMPFIX=\"true\"" >>~/.envConf
    echo "export EDITOR=\"$(which vim)\"" >>~/.envConf

}

function install_git {
    git config --global user.email "florian.stockburger@web.de"
    git config --global user.name "Florian Stockburger"
    git config --global core.editor "vim"
}

function install_vim {
    [ ! -d "${HOME}/.vim" ] && mkdir "${HOME}/.vim"
    if [[ $NOCONFIRM -eq 1 ]]; then
        VIM_TYPE="standard"
    else
        read -p "Select vimrc type (standard or develop). For standard just hit enter: " VIM_TYPE
    fi
    [ "${VIM_TYPE}" != "develop" ] && VIM_TYPE="standard"
    rsync_os "${BASE_DIR}/vim/vimrc_${VIM_TYPE}" "${HOME}/.vim/vimrc"

    curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    local TMP_VIMRC=`mktemp`
    echo "set nocompatible" >$TMP_VIMRC
    echo "filetype off" >>$TMP_VIMRC
    echo "call plug#begin('~/.vim/bundle')" >>$TMP_VIMRC
    grep "^Plug " "${HOME}/.vim/vimrc" >>$TMP_VIMRC
    echo "call plug#end()" >>$TMP_VIMRC
    vim -u "${TMP_VIMRC}" +PlugUpgrade +PlugInstall +PlugUpdate +qall
    rm -v $TMP_VIMRC
    if [[ ! -d ~/.vim/undodir ]]; then
        mkdir ~/.vim/undodir
    fi

}

for job in git zsh vim; do
    log "installing configuration for '$job'"
    install_${job}
    cd "${BASE_DIR}"
done
log "Finish"
