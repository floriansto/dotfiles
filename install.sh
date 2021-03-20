#!/bin/bash

VERSION="v0.2"
BASE_DIR=$(dirname $0)
cd "${BASE_DIR}"
BASE_DIR="${PWD}"

if [[ $1 == "noconfirm" ]]; then
    NOCONFIRM=1
else
    NOCONFIRM=0
fi

function log {
    printf '\e[1;33m%*s\e[0m' "$COLUMNS" '' | tr ' ' -
    printf '\r\e[1;33m-- \e[1;32m%s \e[0m\n' "$*"
}

function rsync_os {
    rsync -a $1 $2
}

function install_zsh {
    OH_MY_ZSH="${HOME}/.oh-my-zsh"
    [ ! -d "${OH_MY_ZSH}" ] && git clone --recursive https://github.com/robbyrussell/oh-my-zsh "${OH_MY_ZSH}"
    cd "${OH_MY_ZSH}"
    [ ! -d "custom/plugins" ] && mkdir -p "custom/plugins"
    cd "custom/plugins"
    [ ! -d "zsh-autosuggestions" ] && git clone https://github.com/zsh-users/zsh-autosuggestions.git
    cd "zsh-autosuggestions"
    git pull
    cd "${OH_MY_ZSH}"
    git pull && git submodule update --init --recursive
    cd "${BASE_DIR}/zsh"
    rsync_os "zshrc" "${HOME}/.zshrc"
    rsync_os "custom/" "${OH_MY_ZSH}/custom"
    backup=""
    [ $OSTYPE != "linux-android" ] && backup="--backup"
    [ -f ~/.envConf ] && [ "`head -n1 ~/.envConf`"="# zsh config file (version: ${VERSION})" ] && source ~/.envConf || mv -vi $backup  ~/.envConf ~/.envConf_`date +%F_%H%M%S`
    #[ -z "$ZSH_THEME" ] && read -p "please enter the zsh theme you wanna use(to use 'mrpi' just hit enter): " ZSH_THEME
    [ -z "$ZSH_THEME" ] && ZSH_THEME="mrpi"

    local ZSH_CUSTOM="${OH_MY_ZSH}/custom"
    echo "# zsh config file (version: $VERSION)" >${HOME}/.envConf
    echo "export ZSH_CUSTOM=\"$ZSH_CUSTOM\"" >>${HOME}/.envConf
    echo "export ZSH_THEME=\"$ZSH_THEME\"" >>${HOME}/.envConf
    echo "export ZSH_DISABLE_COMPFIX=\"true\"" >>${HOME}/.envConf
    echo "export EDITOR=\"$(which vim)\"" >>${HOME}/.envConf

}

function install_git {
    git config --global user.email "florian.stockburger@web.de"
    git config --global user.name "Florian Stockburger"
    git config --global core.editor "vim"
    git config --global credential.helper store
    git config --global pull.rebase true
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

    curl -fLo ${HOME}/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    local TMP_VIMRC=`mktemp`
    echo "set nocompatible" >$TMP_VIMRC
    echo "filetype off" >>$TMP_VIMRC
    echo "call plug#begin('${HOME}/.vim/bundle')" >>$TMP_VIMRC
    grep "^Plug " "${HOME}/.vim/vimrc" >>$TMP_VIMRC
    echo "call plug#end()" >>$TMP_VIMRC
    vim -u "${TMP_VIMRC}" +PlugUpgrade +PlugInstall +PlugUpdate +qall
    rm -v $TMP_VIMRC
    if [[ ! -d ${HOME}/.vim/undodir ]]; then
        mkdir ${HOME}/.vim/undodir
    fi

}

function install_redshift {
    [ ! -d "${HOME}/.config/redshift/" ] && mkdir -p "${HOME}/.config/redshift"
    cp redshift/redshift.conf ${HOME}/.config/redshift/redshift.conf
    systemctl --user enable redshift.service
    systemctl --user start redshift.service
}

function install_terminator {
    [ ! -d "${HOME}/.config/terminator/" ] && mkdir -p "${HOME}/.config/terminator"
    cp terminator/config ${HOME}/.config/terminator/config
}

function install_i3 {
    [ ! -d "${HOME}/.config/i3/" ] && mkdir -p "${HOME}/.config/i3"
    cp i3/config ${HOME}/.config/i3/
    i3-msg restart
}

function install_rofi {
    [ ! -d "${HOME}/.config/rofi/" ] && mkdir -p "${HOME}/.config/rofi"
    cp rofi/config ${HOME}/.config/rofi/
}

function install_libinput_gestures {
    cp libinput-gestures/libinput-gestures.conf ${HOME}/.config/libinput-gestures.conf
    libinput-gestures-setup restart
}

if [[ ! -d $HOME/.config ]]; then
  mkdir $HOME/.config
fi

for job in git zsh vim; do
    log "installing configuration for '$job'"
    install_${job}
    cd "${BASE_DIR}"
done

if [[ $(whoami) != root ]]; then
  for job in redshift terminator i3 libinput_gestures rofi; do
      log "installing configuration for '$job'"
      install_${job}
      cd "${BASE_DIR}"
  done
fi

log "Finish"
