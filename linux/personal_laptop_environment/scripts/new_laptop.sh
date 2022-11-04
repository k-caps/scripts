#!/bin/bash

bprintf () { 
    echo "**********************************************************************************************************************************"
    printf "$1\n"
    echo "**********************************************************************************************************************************"
}

bprintf "To run this script on your laptop run:\nbash -c \"\$(wget https://gitlab.com/k-caps/scripts/-/raw/master/linux/personal_laptop_environment/new_laptop.sh -O -)\""

bprintf "Fix SSH key permissions:\nAdd your ssh keys to ~/.ssh manually using the file browser of your choice.\nOnce copied, press any key to continue.." ; read -n 1 
chmod 0600 ~/.ssh/*
chmod 0644 ~/.ssh/*.pub


bprintf "Get my apps from default repos"
if [ -n "$(which apt)" ]; then
  bprintf  "Debian/*buntu detected, using apt as package manager"
  PKG="apt"
  # Make sure I'm not using the local mirrors on ubuntu:
  sudo sed -i 's|mirror://mirrors.ubuntu.com/mirrors.txt|http://archive.ubuntu.com/ubuntu/|' /etc/apt/sources.list
  sudo apt update
  sudo apt install -y git tmux python3-pip geany vim-nox python3 xfce4-terminal powerline python3-venv wget gthumb timeshift okular youtube-dl xournal zsh
elif [ -n "$(which yum)" ]; then
  bprintf "Fedora/rhel/centos detected, using yum as package manager"
  PKG="yum"
  sudo yum update
  sudo yum install -y git tmux python3-pip geany vim python3 xfce4-terminal powerline python-virtualenv wget gthumb timeshift okular youtube-dl xournal zsh
elif [ -n "$(which pamac)" ]; then
  bprintf "Arch/Manjaro detected, using pacman as package manager"
  sudo pacman -Sy
  # If it doesn't work, make sure "Extra" is enabled in /etc/pacman.conf 
  sudo yes | pacman -S git tmux geany python neovim python-pip python-virtualenv xfce4-terminal powerline wget gthumb timeshift okular xournalpp youtube-dl zsh
else
  bprintf "Install the following packages and then manually continue the script from this point:\ngit tmux python3-pip geany vim-nox python3 xfce4-terminal powerline python3-venv wget gthumb timeshift okular youtube-dl xournal"
  exit
fi

pip install powerline-status

bprintf "Get specialized apps that aren't in the repos:"

bprintf "Hack Nerd font"
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
    bprintf "The new font will only be available in new terminal sessions. After restarting, change Terminal app settings to use Hack Nerd Font."
else
    bprintf "Hack font is already installed, skipping"
fi

# For Gnome only
bprintf "Shell theme, cursors, and icons:"
cd ~/Downloads && mkdir -p Themes && cd Themes
if [[ $(ls | grep WhiteSur |wc -l) != 3 ]]; then
    theme_repos=("cursors" "gtk-theme" "icon-theme")
    mkdir -p $HOME/.local/share/icons/WhiteSur-cursors
    for repo in "${theme_repos[@]}" ; do
        git clone https://github.com/vinceliuice/WhiteSur-$repo
        cd WhiteSur-$repo
	    ./install.sh
        cd ..
    done
    cd ~/Downloads
    bprintf "WhiteSur components have been installed, you will be able to select them from Tweaks at next login."
else
    bprintf "WhiteSur theme is already installed, skipping"
fi

bprintf "Openfortigui VPN:"
# https://hadler.me/linux/openfortigui/
if [[ $PKG == "apt" ]]; then
         # debian
        if [[ $(dpkg -l | grep fortigui | wc -l) == 0 ]]; then
            wget https://apt.iteas.at/iteas/pool/main/o/openfortigui/openfortigui_0.9.5-1_amd64_focal.deb -O openfortigui.deb
            sudo apt install ./openfortigui.deb -y
            rm -f openfortigui.deb
        else
            bprintf "Openfortgui is already installed, skipping"   
        fi
elif [[ $PKG == "yum" ]]; then
	if [[ $(which openfortigui | wc -l) == 0 ]]; then
		sudo dnf install qt5-qtbase-devel openssl-devel qtkeychain-qt5-devel -y
		mkdir ~/Downloads/Openfortgui && cd ~/Downloads/Openfortgui
		git clone https://github.com/theinvisible/openfortigui.git
		cd openfortigui && git submodule init && git submodule update
		qmake-qt5 && make -j4
		
		# install it as an application
		sudo cp openfortigui/app-entry/openfortigui.png /usr/share/pixmaps
		sudo cp openfortigui/app-entry/openfortigui.desktop /usr/share/applications
		sudo cp openfortigui/openfortigui /usr/bin/
	else
	    bprintf "Openfortgui is already installed, skipping"
	fi
fi
# must add AUR!
cd ~/Downloads

## Albert global search: https://software.opensuse.org/download.html?project=home:manuelschneid3r&package=albert
# not necessary on gnome, must add conditional for apt/yum/pamac
#if [[ $(dpkg -l | grep albert | wc -l) == 0 ]]; then
#    wget https://download.opensuse.org/repositories/home:/manuelschneid3r/Debian_11/amd64/albert_0.17.3-0_amd64.deb -O albert.deb
#    sudo apt install ./albert.deb -y
#    rm -f albert.deb
#else
#    bprintf "Albert is already installed, skipping"
#fi

bprintf "Docker:"
if [[ $PKG == "apt" ]]; then
	if [[ $(dpkg -l | grep docker | wc -l) == 0 ]]; then
	    curl -fsSL https://get.docker.com -o get-docker.sh
	    sudo sh get-docker.sh
	    rm get-docker.sh
	    sudo groupadd docker
	    sudo usermod -aG docker $USER
	else
	    bprintf "Docker is already installed, skipping"   
	fi
elif [[ $PKG == "yum" ]]; then
	if [[ $(which docker | wc -l) == 0 ]]; then
		sudo dnf -y install dnf-plugins-core
		sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
		sudo dnf install -y  docker-ce docker-ce-cli containerd.io docker-compose-plugin
		sudo groupadd docker
		sudo usermod -aG docker $USER
	fi
fi

bprintf "Setting up git scripts repo"
if [[ $(ls /Dev/git/scripts/ | wc -l) == 0 ]]; then
    cd ~ && mkdir -p Dev/git && cd Dev/git
    git clone git@gitlab.com:k-caps/scripts.git
    ln -s ~/Dev/git/scripts/linux/personal_laptop_environment/scripts ~/Scripts
else
    bprintf "Scripts directory is already in place, skipping"
fi

bprintf "Installing venvmgr"
wget https://gitlab.com/k-caps/venvmgr/-/raw/main/venvmgr.sh && source ./venvmgr.sh -I && rm venvmgr.sh

bprintf "Get gnome extensions"
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

# Install Search Light extension via git, more reliable than the extension script
git clone http://github.com/icedman/search-light
cd search-light && make && cd .. && rm -rf search-light
rm -rf 'Gnome Extensions'

bprintf "Fix touchscreen scrolling in firefox" # only appears to be necessary on debian based distros
if [[ $PKG == "apt" ]]; then
	if [[ $(grep MOZ_USE_XINPUT2 /etc/security/pam_env.conf | wc -l) == 0 ]]; then
	    bprintf "open about:config in firefox, and set dom.w3c_touch_events.enabled=1 (default is 2)."
	    sleep 5 && bprintf "Once you have updated the settings in Firefox click any key to continue.." ; read -n 1
	    sudo sh -c 'echo MOZ_USE_XINPUT2 DEFAULT=1 >> /etc/security/pam_env.conf'
	else
	   bprintf "Touchscreen scrolling is already enabled for Firefox, skipping"
	fi
fi

bprintf "Change to oh my zsh"
if [[ $(echo $SHELL | grep zsh |wc -l) == 0 ]]; then
    bash -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
    cd ~
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    sed -i "s|/home/kobi|$HOME|g" ~/.zshrc
    zsh
else
    bprintf "The default shell is already ZSH, skipping"
fi

bprintf "Downloading dotfiles"
cd ~/Downloads
dotfiles=("aliases" "bashrc" "zshrc" "vimrc" "tmux.conf")
for file in "${dotfiles[@]}" ; do
	wget https://gitlab.com/k-caps/scripts/-/raw/master/linux/personal_laptop_environment/dotfiles/$file
	mv $file ~/.$file
    chmod 0755 ~/.aliases
done

bprintf "Disable default systemd timeout"
# affects shutdown time on debian, ubuntu, and fedora. maybe others as well
if [[ $(grep "DefaultTimeoutStopSec=3s" /etc/systemd/system.conf) == 0 ]]; then
    sudo sh -c 'echo "DefaultTimeoutStopSec=3s" >> /etc/systemd/system.conf'
else
    bprintf "The default systemd timeout is already 3 seconds, skipping"
fi

# Reboot to make all changes take place
bprintf  "System has been configured successfully!\nA reboot is necessary for some changes.\nPress any key to reboot now." ; read -n 1
#sudo shutdown -r now


