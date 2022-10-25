#!/bin/bash

printf "To run this script on your laptop run:\n"
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
if [ -n "$(which apt)" ]; then
  printf  "\n\nDebian/*buntu detected, using apt\n\n"
  sudo apt update
  sudo apt install -y git tmux python3-pip geany vim-nox python3 xfce4-terminal powerline python3-venv wget gthumb timeshift okular youtube-dl xournal
elif [ -n "$(which yum)" ]; then
  printf "\n\nfedora/rhel/centos detected, using yum\n\n"
  sudo yum update
  sudo yum install -y git tmux python3-pip geany vim python3 xfce4-terminal powerline python3-venv wget gthumb timeshift okular youtube-dl xournal
elif [ -n "$(which pamac)" ]; then
  printf "\n\nArch/Manjaro detected, using pacman\n\n"
  sudo pacman -Sy
  # If it doesn't work, make sure "Extra" is enabled in /etc/pacman.conf 
  sudo yes | pacman -S git tmux geany python neovim python-pip python-virtualenv xfce4-terminal powerline wget gthumb timeshift okular xournalpp youtube-dl
else
  echo Install the following packages and then manually continue the script from this point:
  echo "git tmux python3-pip geany vim-nox python3 xfce4-terminal powerline python3-venv wget gthumb timeshift okular youtube-dl xournal"
  exit
fi

pip install powerline-status

# Get specialized apps that aren't in the repos:

# Patched nerd font with all OS glyphs
if [[ $(fc-list | grep "Hack Nerd Font" | wc -l) == 0 ]]; then
    cd ~/Downloads
    mkdir -p ~/.local/share/fonts/
    mkdir hack_font_temp_dir && cd hack_font_temp_dir
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/Hack.zip -O Hack.zip
    unzip Hack.zip 'Hack Regular Nerd Font Complete.ttf'
    mv 'Hack Regular Nerd Font Complete.ttf' ~/.local/share/fonts/'Hack Regular Nerd Font Complete.ttf'
    fc-cache -f -v
    cd .. && rm -rf hack_font_temp_dir
    echo "The new font will only be available in new terminal sessions. After restarting Change Terminal app settings to use Hack Nerd Font."
else
    echo Hack font is already installed, skipping
fi

# Shell theme, cursors, and icons:
cd ~/Downloads && mkdir -p Themes && cd Themes
if [[ $(ls | grep WhiteSur |wc -l) != 3 ]]; then
    theme_repos=("cursors" "gtk-theme" "icon-theme")
    for repo in "${theme_repos[@]}" ; do
        git clone https://github.com/vinceliuice/WhiteSur-$repo
        cd WhiteSur-$repo
	    ./install.sh
        cd ..
    done
    cd ~/Downloads
    echo "WhiteSur components have been installed, you will be able to select them from Tweaks at next login."
else
    echo WhiteSur theme is already installed, skipping   
fi

# Openfortigui VPN: https://hadler.me/linux/openfortigui/
# debian
if [[ $(dpkg -l | grep fortigui | wc -l) == 0 ]]; then
    wget https://apt.iteas.at/iteas/pool/main/o/openfortigui/openfortigui_0.9.5-1_amd64_focal.deb -O openfortigui.deb
    sudo apt install ./openfortigui.deb -y
    rm -f openfortigui.deb
else
    echo Openfortgui is already installed, skipping   
fi
# must add AUR!

## Albert global search: https://software.opensuse.org/download.html?project=home:manuelschneid3r&package=albert
# not necessary on gnome, must add conditional for apt/yum/pamac
#if [[ $(dpkg -l | grep albert | wc -l) == 0 ]]; then
#    wget https://download.opensuse.org/repositories/home:/manuelschneid3r/Debian_11/amd64/albert_0.17.3-0_amd64.deb -O albert.deb
#    sudo apt install ./albert.deb -y
#    rm -f albert.deb
#else
#    echo Albert is already installed, skipping   
#fi

# Docker
if [[ $(dpkg -l | grep docker | wc -l) == 0 ]]; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    rm get-docker.sh
    sudo groupadd docker
    sudo usermod -aG docker $USER
else
    echo Docker is already installed, skipping   
fi

# Set custom environment
if [[ $(which venvmgr | wc -l) == 0 ]]; then
    cd ~ && mkdir -p Dev/git && cd Dev/git
    git clone git@gitlab.com:k-caps/scripts.git
    ln -s ~/Dev/git/scripts/linux/personal_laptop_environment/scripts ~/Scripts
    cd ~/Scripts && source venvmgr.sh -I
else
    echo Scripts directory is in place, skipping
fi

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
# in order the extensions below are:
# Click To Close Overview, Clipboard Indicator, Floating Dock, GSConnect, Hibernate Status Button, Just Perfection, Screenshot Directory, Shelltile, Sound IO Device Chooser, Tray Icons
g_extension_ids=("3826" "779" "3730" "1319" "755" "3843" "4031" "657" "906" "2890")
for ext in "${g_extension_ids[@]}" ; do
	./gnome-shell-extension-installer $ext
done
cd ..
rm -rf 'Gnome Extensions'

# Fix touchscreen scrolling in firefox
if [[ $(grep MOZ_USE_XINPUT2 /etc/security/pam_env.conf) == 0 ]]; then
    echo "open about:config in firefox, and set dom.w3c_touch_events.enabled=1 (default is 2)."
    sleep 5 && read -p "Once you have updated the settings in Firefox click any key to continue.." -n 1 -s
    sudo sh -c 'echo MOZ_USE_XINPUT2 DEFAULT=1 >> /etc/security/pam_env.conf'
else
    echo Touchscreen scrolling is already enabled for Firefox, skipping
fi

# Change to oh my zsh
if [[ $(echo $SHELL | grep zsh |wc -l) == 0 ]]; then
    sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
    cd ~
    touch .aliases
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/  zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/ zsh-autosuggestions
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    curl https://gitlab.com/k-caps/scripts/-/raw/master/linux/zsh/zshrc | sed "s|/home/kobi|$HOME|g"  > ~/.zshrc
    zsh
else
    echo The default shell is already ZSH, skipping
fi

# Disable default systemd timeout, affects shutdown time
if [[ $(grep "DefaultTimeoutStopSec=3s" /etc/systemd/system.conf) == 0 ]]; then
    sudo sh -c 'echo "DefaultTimeoutStopSec=3s" >> /etc/systemd/system.conf'
else
    echo The default systemd timeout is already 3 seconds, skipping
fi

# Reboot to make all changes take place
echo "System has been configured successfully!"
read -n "Press any key to reboot.." -n 1 -s
sudo shutdown -r now


