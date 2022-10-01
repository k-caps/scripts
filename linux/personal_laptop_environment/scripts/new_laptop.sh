#!/bin/bash

# Manually add my ssh keys directory for git clones
read -p "Add your ssh keys to ~/.ssh and click any key to continue" -n 1 -s
chmod 0600 ~/.ssh/*
chmod 0644 ~/.ssh/*.pub

# Make sure I'm not using the local mirrors:
sudo sed 's|mirror://mirrors.ubuntu.com/mirrors.txt|http://archive.ubuntu.com/ubuntu/|' /etc/apt/sources.list
sudo apt update ; sudo apt upgrade

# Disable default systemd timeout, affects shutdown time
sudo sh -c 'echo "DefaultTimeoutStopSec=3s" >> /etc/systemd/system.conf'

# Get the basics
sudo apt install -y git tmux python3-pip geany vim python3 xfce4-terminal powerline python3-venv wget gthumb timeshift okular youtube-dl xournal 
pip install powerline-status

# Get specialized apps that aren't in the repos:

# Patched nerd font with all OS glyphs
cd ~/Downloads
mkdir -p ~/.local/share/fonts/
mkdir hack_font_temp_dir && cd hack_font_temp_dir
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/Hack.zip -O Hack.zip
unzip Hack.zip 'Hack Regular Nerd Font Complete.ttf'
mv 'Hack Regular Nerd Font Complete.ttf' ~/.local/share/fonts/'Hack Regular Nerd Font Complete.ttf'
fc-cache -f -v
cd .. && rm -rf hack_font_temp_dir
read -p "Change Terminal app settings to use Hack Nerd Font and click any key to continue" -n 1 -s

# Openfortigui VPN: https://hadler.me/linux/openfortigui/
wget https://apt.iteas.at/iteas/pool/main/o/openfortigui/openfortigui_0.9.5-1_amd64_focal.deb -O openfortigui.deb
sudo apt install ./openfortigui.deb -y
rm -f openfortigui_0.9.5-1_amd64_focal.deb

# Albert global search: https://software.opensuse.org/download.html?project=home:manuelschneid3r&package=albert
wget https://download.opensuse.org/repositories/home:/manuelschneid3r/xUbuntu_20.04/amd64/albert_0.17.3-0_amd64.deb -O albert.deb
sudo apt install ./albert.deb -y
rm -f albert_0.17.3-0_amd64.deb

# Change to oh my zsh
sh -c "$(wget https://gitlab.com/k-caps/scripts/-/raw/master/linux/zsh/config_zsh.sh -O -)"

# Set custom environment
cd ~ && mkdir -P Dev/git && cd Dev/git
git clone git@gitlab.com:k-caps/scripts.git
ln -s ~/Dev/git/scripts/linux/personal_laptop_environment/scripts ~/Scripts
cd ~/Scripts && source venvmgr.sh -I

# Fix touchscreen scrolling in firefox
echo "open about:config in firefox, and set dom.w3c_touch_events.enabled=1 (default is 2)."
sleep 5 && read -p "Once you have updated the settings in Firefox click any key to continue (will reboot)" -n 1 -s
echo MOZ_USE_XINPUT2 DEFAULT=1 >> /etc/security/pam_env.conf
sudo shutdown -r now


