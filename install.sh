#!/bin/bash

VERSION="v0.1"
BASE_DIR=$(dirname $0)
cd "${BASE_DIR}"
BASE_DIR="${PWD}"

function log {
	printf '\e[1;33m%*s\e[0m' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
 	printf '\r\e[1;33m-- \e[1;32m%s \e[0m\n' "$*"
}

function install_zsh {
    cd "${BASE_DIR}/zsh"
    [ ! -d "oh-my-zsh" ] && git clone --recursive https://github.com/robbyrussell/oh-my-zsh
    cd "custom/plugins"
    [ ! -d "zsh-autosuggestions" ] && git clone https://github.com/zsh-users/zsh-autosuggestions.git
    cd "zsh-autosuggestions"
    git pull
    cd "${BASE_DIR}/zsh"
    cd "oh-my-zsh"
    git pull && git submodule update --init --recursive
    cd "${BASE_DIR}/zsh"
    for file in oh-my-zsh zshrc; do
		[ -L "${HOME}/.${file}" ] && rm -v "${HOME}/.${file}"
		ln -sivT "`readlink -f ${file}`" "${HOME}/.${file}"
	done
    [ -f ~/.envConf ] && [ "`head -n1 ~/.envConf`"="# zsh config file (version: ${VERSION})" ] && source ~/.envConf ||
		mv -vi --backup ~/.envConf ~/.envConf_`date +%F_%H%M%S`
    [ -z "$ZSH_THEME" ] && read -p "please enter the zsh theme you wanna use(to use 'bira' just hit enter): "
	[ -z "$ZSH_THEME" ] && ZSH_THEME="bira"

    local ZSH_CUSTOM="${BASE_DIR}/zsh/custom"
    echo "# zsh config file (version: $VERSION)" >~/.envConf
	echo "ZSH_CUSTOM=\"$ZSH_CUSTOM\"" >>~/.envConf
	echo "ZSH_THEME=\"$ZSH_THEME\"" >>~/.envConf

}

function install_git {
    git config --global user.email "93-orangen@web.de"
    git config --global user.name "Florian Stockburger"
    git config --global core.editor "vim"
}

function install_vim {
    [ -L "${HOME}/.vim" ] && rm -v "${HOME}/.vim"
    ln -sivT "${BASE_DIR}/vim" "${HOME}/.vim"
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    local TMP_VIMRC=`mktemp`
    echo "set nocompatible" >$TMP_VIMRC
	echo "filetype off" >>$TMP_VIMRC
	echo "call plug#begin('~/.vim/bundle')" >>$TMP_VIMRC
	grep "^Plug " "${BASE_DIR}/vim/vimrc" >>$TMP_VIMRC
	echo "call plug#end()" >>$TMP_VIMRC
	vim -u "${TMP_VIMRC}" +PlugUpgrade +PlugInstall +PlugUpdate +qall
	rm -v $TMP_VIMRC

}

for job in git zsh vim; do
	log "installing configuration for '$job'"
	install_${job}
	cd "${BASE_DIR}"
done
log "Finish"
