#!/bin/bash

# To run this script on your laptop run:
printf 'sh -c "$(wget https://gitlab.com/k-caps/scripts/-/raw/master/linux/personal_laptop_environment/new_laptop.sh -O -)"\n'

# Fix SSH key permissions
printf "Add your ssh keys to ~/.ssh manually using the file browser of your choice.\n" 
read -n "Once copied, press any key to continue.." -n 1 -s
chmod 0600 ~/.ssh/*
chmod 0644 ~/.ssh/*.pub

# Make sure I'm not using the local mirrors on ubuntu:
sudo sed 's|mirror://mirrors.ubuntu.com/mirrors.txt|http://archive.ubuntu.com/ubuntu/|' /etc/apt/sources.list
sudo apt update ; sudo apt upgrade

# Get the basics
sudo apt install -y git tmux python3-pip geany vim-nox python3 xfce4-terminal powerline python3-venv wget gthumb timeshift okular youtube-dl xournal
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
echo "The new font will only be available in new terminal sessions. After restarting Change Terminal app settings to use Hack Nerd Font."

# Shell theme, cursors, and icons:
mkdir -p Themes && cd Themes
theme_repos=("cursors" "gtk-theme" "icon-theme")
for repo in "${theme_repos[@]}" ; do
        git clone https://github.com/vinceliuice/WhiteSur-$repo
        cd WhiteSur-$repo
	./install.sh
	cd ..
done
echo "WhiteSur components have been installed, you will be able to select them from Tweaks at next login."
cd ~/Downloads

# Openfortigui VPN: https://hadler.me/linux/openfortigui/
wget https://apt.iteas.at/iteas/pool/main/o/openfortigui/openfortigui_0.9.5-1_amd64_focal.deb -O openfortigui.deb
sudo apt install ./openfortigui.deb -y
rm -f openfortigui.deb

# Albert global search: https://software.opensuse.org/download.html?project=home:manuelschneid3r&package=albert
wget https://download.opensuse.org/repositories/home:/manuelschneid3r/Debian_11/amd64/albert_0.17.3-0_amd64.deb -O albert.deb
sudo apt install ./albert.deb -y
rm -f albert.deb

# Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
rm get-docker.sh
sudo groupadd docker
sudo usermod -aG docker $USER

# Set custom environment
cd ~ && mkdir -P Dev/git && cd Dev/git
git clone git@gitlab.com:k-caps/scripts.git
ln -s ~/Dev/git/scripts/linux/personal_laptop_environment/scripts ~/Scripts
cd ~/Scripts && source venvmgr.sh -I

cd ~/Downloads
dotfiles=("aliases" "bashrc" "zshrc" "vimrc" "tmux.conf")
for file in "${dotfiles[@]}" ; do
	wget https://gitlab.com/k-caps/scripts/-/raw/master/linux/personal_laptop_environment/dotfiles/$file
	mv $file ~/.$file
done

# Get gnome extensions
mkdir 'Gnome Extensions' && cd 'Gnome Extensions'
wget -O gnome-shell-extension-installer "https://github.com/brunelli/gnome-shell-extension-installer/raw/master/gnome-shell-extension-installer"
chmod +x gnome-shell-extension-installer
g_extension_ids=("1319" "3730" "2" "755" "906" "2890" "779" "3826")
for ext in "${g_extension_ids[@]}" ; do
	./gnome-shell-extension-installer $ext
done
cd ..
rm -rf 'Gnome Extensions'

# Fix touchscreen scrolling in firefox
echo "open about:config in firefox, and set dom.w3c_touch_events.enabled=1 (default is 2)."
sleep 5 && read -p "Once you have updated the settings in Firefox click any key to continue.." -n 1 -s
echo MOZ_USE_XINPUT2 DEFAULT=1 >> /etc/security/pam_env.conf

# Change to oh my zsh
sh -c "$(wget https://gitlab.com/k-caps/scripts/-/raw/master/linux/zsh/config_zsh.sh -O -)"

# Disable default systemd timeout, affects shutdown time
sudo sh -c 'echo "DefaultTimeoutStopSec=3s" >> /etc/systemd/system.conf'

# Reboot to make all changes take place
echo "System has been configured successfully!"
read -n "Press any key to reboot.." -n 1 -s
sudo shutdown -r now


