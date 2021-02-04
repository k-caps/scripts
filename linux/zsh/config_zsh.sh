#!/bin/bash

#Packages
if [ -n "$(which apt)" ]; then
  printf  "\n\n*buntu detected, using apt\n\n"
  PKG=apt
elif [ -n "$(which yum)" ]; then
  printf "\n\nfedora/rhel/centos detected, using yum\n\n"
  PKG=yum
else
  echo Install the following packages and then manually continue the script from this point:
  echo git zsh wget curl
  exit
fi

$PKG install git zsh wget curl -y
sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
cd ~
touch .aliases
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
curl https://gitlab.com/k-caps/linux-scripts/-/raw/master/zshrc | sed "s|/home/kobi|$HOME|g"  > ~/.zshrc
zsh
