#!/bin/bash
BKPDIR=~/Backups/daily_backup_`date +%d-%m_%Y`/
mkdir -p $BKPDIR


# If I want to backup the whole computer, I would run the script as sudo and set "/" instead of a list of directories, with the following FSs exluded:
#/dev /proc, /sys, /mnt, /media, /run
# OR use the "--one-file-system flag" and backup each filesystem separately. 

# All of the excludes are relative to ALL of the folders to backup - EG, if I have a Postman folder in ~/scripts and in ~/eBooks, both will be excluded.

GZIP=-9  tar -czvf $BKPDIR/files.tar.gz \
--exclude='BlackmagicDesign' \
--exclude='Image-Line' \
--exclude='ExperdaHours' \
--exclude='rundeck' \
--exclude='Postman' \
--exclude='Screenshots' \
~/scripts \
~/eBooks \
~/Documents \
~/Pictures \
~/Dev

# I have two commands for making data and configuration backups separately, but I can run just one with everything into one file if I wanted.

GZIP=-9  tar -czvf $BKPDIR/config.tar.gz \
~/.config \
~/.ssh \
~/SoftMaker \
~/Templates \
~/.p10k.zsh  \
~/.zshrc \
~/.aliases \
~/.davmail.properties \
~/.vimrc \
~/.bashrc \
~/.gitconfig
