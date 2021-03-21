# dotfiles
Install configuration files for some programs on unix machines to simplify the setup.

# Requirements
The following packages are needed
```sh
git vim curl
```

# Usage
Run
```
./install.sh --help
```
to get usage instructions

## Commandline parameters
| Parameter | Values | is flag | Description |
|-|-|-|-|
| -v<br>--vim | standard,develop | no | Option for vim config, develop contains some more plugins |
| -e<br>--exclude-i3-block | filenames from `i3/blocks` folder without extension | no | Exclude blocks for the `i3status-rs` configuration |
| -de<br>--device-eth | ethernet device | no | Ethernet device for ethernet block for `i3status-rs` |
| -dw<br>--device-wifi | wifi device | no | WiFi device for wifi block for `i3status-rs` |
| -g<br>--graphical | - | yes | Whether dotfiles for a graphical environment should be installed |\
| -h<br>--help | - | yes | Display usage instructions |

