#!/bin/bash

# Manually add my ssh keys directory for git clones

# Get the basics
sudo apt install -y git tmux python3-pip geany vim python3 xfce4-terminal fonts-hack-ttf powerline python3-venv
pip install powerline-status

# Change to oh my zsh
sh -c "$(wget https://gitlab.com/k-caps/scripts/-/raw/master/linux/zsh/config_zsh.sh -O -)"

# Set custom environment
cd ~ && mkdir -P Dev/git && cd Dev/git
git clone git@gitlab.com:k-caps/scripts.git
ln -s ~/Dev/git/scripts/linux/personal_laptop_environment/scripts ~/Scripts
cd ~/Scripts && source venvmgr.sh -I

# Fix touchscreen scrolling in firefox
echo "open about:config in firefox, and set dom.w3c_touch_events.enabled=1 (default is 2)."
echo MOZ_USE_XINPUT2 DEFAULT=1 >> /etc/security/pam_env.conf
sudo shutdown -r now


