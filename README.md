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
apt install wget git vim zsh curl
```
### Arch based systems
```sh
pacman -S wget git vim zsh curl
```
## Get the source
```git
git clone https://gitea.flo-sto.de/flo/dotfiles.git 
```

# Usage
Run
```
./install.sh
```
from inside the cloned repository to install the config files.
