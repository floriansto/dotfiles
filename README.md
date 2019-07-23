# dotfiles
Install configuration files for some programs on unix machines to simplify the setup.

# Supported programs
* git
* vim
* zsh

# Installation
## Needed Packages
### Debian based systems
```sh
apt install wget git vim zsh
```
### Arch based systems
```sh
pacman -S wget git vim zsh
```
## Get the source
```git
git clone http://gitea:3000/flo/dotfiles.git 
```

# Usage
Run
```
./install.sh
```
from inside the cloned repository to install the config files.