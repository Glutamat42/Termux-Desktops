#!/bin/bash

# base openbox configuration
sudo apt-get install -y python3-xdg lxterminal tint2 feh rofi

mkdir -p $HOME/.config/openbox
cp -r openbox $HOME/.config/
cp -r tint2 $HOME/.config/

# cli utils
sudo apt-get install -y nano htop xz-utils

# base user applications
sudo apt-get install thunar l3afpad
