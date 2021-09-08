#!/bin/bash

VERSION="v0.2"
BASE_DIR=$(dirname $0)
cd "${BASE_DIR}"
BASE_DIR="${PWD}"
I3_BLOCKS="i3/blocks"

function usage() {
  echo "Usage $0 [options [parameters]]"
  echo ""
  echo "Options"
  echo " -v,--vim              [standard|develop] Option for vim config, default: standard"
  echo " -e,--exclude-i3-block [block] Exclude a block from i3status (block names"
  echo "                       are filenames from i3/blocks/ folder without extension)"
  echo " -de,--device-eth      [dev] Ethernet device (used for i3status)"
  echo " -dw,--device-wifi     [dev] WiFi device (used for i3status)"
  echo " -g,--graphical        Whether dotfiles for a graphical environment should be installed"
  echo " -h,--help             Print this help"
}

function check_vim() {
  if [[ "${vim}" != "standard" && "${vim}" != "develop" ]]; then
    echo "Unknown parameter \"${vim}\" for the -v or --vim option"
    echo "Allowed values: standard, develop"
    exit 1
  fi
}

function check_i3() {
  errorlist=()
  haserrors=0
  for i in ${exclude_i3[@]}; do
    if [[ ! -f "${I3_BLOCKS}/${i}.toml" ]]; then
      errorlist+=("${I3_BLOCKS}/${i}.toml")
      haserrors=1
    fi
  done
  if [[ ${haserrors} -eq 1 ]]; then
    echo "The following blocks cannot be found:"
    echo " ${errorlist[@]}"
    exit 1
  fi
}

function get_i3_blocks() {
  for i in $(ls ${I3_BLOCKS}/*.toml); do
    f=$(basename ${i} .toml)
    if [[ ! "${exclude_i3[@]}" =~ "${f}" ]];then
      include_i3+=(${f})
    fi
  done
}

function net_error() {
  devs=$(ls /sys/class/net | tr '\n' ' ')
  echo "Unknown device $1"
  echo "Allowed devices: ${devs[@]}"
  exit 1
}

function log {
    printf '\e[1;33m%*s\e[0m' "$COLUMNS" '' | tr ' ' -
    printf '\r\e[1;33m-- \e[1;32m%s \e[0m\n' "$*"
}

function install_gtk3() {
  if [[ ! -d "${HOME}/.config/gtk-3.0" ]]; then
    mkdir "${HOME}/.config/gtk-3.0"
  fi
  cp gtk3/settings.ini "${HOME}/.config/gtk-3.0/settings.ini"
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
    cp "zshrc" "${HOME}/.zshrc"
    cp -r "custom/" "${OH_MY_ZSH}/custom"
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
    git config --global user.email "stockburger.florian@gmail.com"
    git config --global user.name "Florian Stockburger"
    git config --global core.editor "vim"
    git config --global credential.helper store
    git config --global pull.rebase true
    git config --global init.defaultBranch main
}

function install_vim {
    [ ! -d "${HOME}/.vim" ] && mkdir "${HOME}/.vim"
    cp "${BASE_DIR}/vim/vimrc_${vim}" "${HOME}/.vim/vimrc"

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
}

function install_terminator {
    [ ! -d "${HOME}/.config/terminator/" ] && mkdir -p "${HOME}/.config/terminator"
    cp terminator/config ${HOME}/.config/terminator/config
}

function install_sway {
    [ ! -d "${HOME}/.config/sway/" ] && mkdir -p "${HOME}/.config/sway"
    cp -r sway/* ${HOME}/.config/sway/
}

function install_i3 {
    [ ! -d "${HOME}/.config/i3/" ] && mkdir -p "${HOME}/.config/i3"
    cp -r i3/* ${HOME}/.config/i3/
    [ ! -d "${HOME}/.config/dunst" ] && mkdir -p "${HOME}/.config/dunst"
    cp dunst/dunstrc ${HOME}/.config/dunst/dunstrc

    include_i3_ordered=()
    status_order=$(cat i3/i3status-order.conf)
    for i in ${status_order[@]}; do
      if [[ "${include_i3[@]}" =~ "${i}" ]];then
        f="${I3_BLOCKS}/${i}.toml"
        if [[ "${i}" == "net_eth" || "${i}" == "net_wifi" ]];then
          if [[ "${i}" == "net_eth" && ${dev_eth} != "" ]]; then
            out=$(cat ${f} | sed "s/%DEVICE%/${dev_eth}/")
          elif [[ "${i}" == "net_wifi" && ${dev_wifi} != "" ]]; then
            out=$(cat ${f} | sed "s/%DEVICE%/${dev_wifi}/")
          else
            out=""
          fi
        else
          out=$(cat ${f})
        fi
        echo "${out}" >> "${HOME}/.config/i3/i3status-rs.toml"
        echo "" >> "${HOME}/.config/i3/i3status-rs.toml"
        include_i3_ordered+=(${i})
      fi
    done
    echo "Included i3status-rs blocks:"
    echo "${include_i3_ordered[@]}"
}

function install_rofi {
    [ ! -d "${HOME}/.config/rofi/" ] && mkdir -p "${HOME}/.config/rofi"
    cp rofi/config.rasi ${HOME}/.config/rofi/
}

function install_wofi {
    [ ! -d "${HOME}/.config/wofi/" ] && mkdir -p "${HOME}/.config/wofi"
    cp -r wofi/* ${HOME}/.config/wofi/
}

function install_alacritty {
    [ ! -d "${HOME}/.config/alacritty/" ] && mkdir -p "${HOME}/.config/alacritty"
    cp -r alacritty/* ${HOME}/.config/alacritty/
}

function install_libinput_gestures {
    cp libinput-gestures/libinput-gestures.conf ${HOME}/.config/libinput-gestures.conf
}

function install_systemd_user {
    [ ! -d "${HOME}/.config/systemd/user/" ] && mkdir -p "${HOME}/.config/systemd/user/"
    cp -r systemd_user/* ${HOME}/.config/systemd/user/
    systemctl --user daemon-reload
    for f in "${HOME}/.config/systemd/user/*.service"; do
      echo "Start and enable $(basename $f)"
      systemctl --user start $(basename $f)
      systemctl --user enable $(basename $f)
    done
}

vim="standard"
vim_opt=0
exclude_i3=()
include_i3=()
dev_eth=""
dev_wifi=""
graphical=0
while [[ ! -z "$1" ]]; do
  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
    exit 0
  elif [[ "$1" == "-v" || "$1" == "--vim" ]]; then
    if [[ ${vim_opt} -gt 0 ]]; then
      echo "The -v,--vim option is only allowed once"
      usage
      exit 1
    fi
    vim="$2"
    vim_opt=1
    shift
  elif [[ "$1" == "-e" || "$1" == "--exclude-i3-block" ]]; then
    exclude_i3+=($2)
    shift
  elif [[ "$1" == "-de" || "$1" == "--device-eth" ]]; then
    dev_eth="$2"
    if [[ ! -e /sys/class/net/${dev_eth} ]]; then
      net_error ${dev_eth}
    fi
    shift
  elif [[ "$1" == "-dw" || "$1" == "--device-wifi" ]]; then
    dev_wifi="$2"
    if [[ ! -e /sys/class/net/${dev_wifi} ]]; then
      net_error ${dev_wifi}
    fi
    shift
  elif [[ "$1" == "-g" || "$1" == "--graphical" ]]; then
    graphical=1
  else
    echo "Unknown option $1"
    usage
    exit 1
  fi
  shift
done
check_vim
check_i3
get_i3_blocks

if [[ ! -d $HOME/.config ]]; then
  mkdir $HOME/.config
fi

for job in git zsh vim; do
    log "installing configuration for '$job'"
    install_${job}
    cd "${BASE_DIR}"
done

if [[ ${graphical} -gt 0 ]]; then
  for job in redshift alacritty terminator i3 libinput_gestures rofi wofi gtk3 sway systemd_user; do
      log "installing configuration for '$job'"
      install_${job}
      cd "${BASE_DIR}"
  done
fi

log "Finish"
