#!/bin/bash

BKPDIR=~/Backups/daily_backup_`date +%d-%m_%Y`/
mkdir -p $BKPDIR

GZIP=-9  tar -czvf $BKPDIR/files.tar.gz \
--exclude='BlackmagicDesign' \
--exclude='Image-Line' \
--exclude='ExperdaHours' \
--exclude='rundeck' \
--exclude='Postman' \
--exclude='Screenshots' \
--exclude='Lumix' \
~/scripts \
~/eBooks \
~/Documents \
~/Pictures \
~/Dev \
~/.p10k.zsh  \
~/.zshrc \
~/.aliases \
~/.davmail.properties \
~/.vimrc \
~/.bashrc \
~/.gitconfig \
~/.tmux.conf
~/Backups/Microsoft_Office_365_logged_in_backup.cxarchive \
~/Backups/Working_Office_365.cxarchive

GZIP=-9  tar -czvf $BKPDIR/config.tar.gz \
~/.config \
~/.ssh \
~/SoftMaker \
~/Templates \

