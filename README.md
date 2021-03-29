# dotfiles
Install configuration files for some programs on unix machines to simplify the setup.

# Requirements
The following packages are needed
```sh
git vim curl
```
To get new wallpapers based on the bing image of the day you need to clone the repository [https://github.com/markasoftware/bing-wallpaper-linux.git](https://github.com/markasoftware/bing-wallpaper-linux.git) to your `/opt` directory.

# Usage
Run
```
./install.sh --help
```
to get usage instructions

## Commandline parameters
| Parameter | Values | is flag | Description |
|-|-|-|-|
| -v<br>--vim | standard, develop | no | Option for vim config, develop contains some more plugins. Default value: `standard` |
| -e<br>--exclude-i3-block | filenames from `i3/blocks` folder **without** extension | no | Exclude blocks for the `i3status-rs` configuration |
| -de<br>--device-eth | ethernet device | no | Ethernet device for ethernet block for `i3status-rs` |
| -dw<br>--device-wifi | wifi device | no | WiFi device for wifi block for `i3status-rs` |
| -g<br>--graphical | - | yes | Whether dotfiles for a graphical environment should be installed |\
| -h<br>--help | - | yes | Display usage instructions |

## Notes
* If no network device is specified (neither ethernet nor wifi), no network block will be enabled in the `i3status-rs` bar.
* The blocks in the `i3status-rs` bar are ordered depending on the file `i3/i3status-order.conf`.
* The `-e` option can be passed multiple times to exclude more than one block.

When not running with the `-g` option, only the following files are installed:
```
git vim zsh
```

