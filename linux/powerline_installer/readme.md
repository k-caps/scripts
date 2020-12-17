
**Installation:**    
`wget https://raw.githubusercontent.com/k-caps/linux-scripts/master/powerline_installer/install.sh && sudo sh install.sh`       

This script installs powerline and a patched font, and configures bash and vim to use it.    
You must still manually change the font your terminal emulator app uses to "Hack Regular" after the script runs, or your prompt will look bugged.

If the script fails to install the font, you can download and install it manually from this drive link or download from the official git repository:
```
https://drive.google.com/file/d/1rKGE8jbO5iJPtatJPKqQ8rvT0BqlmfN8/view?usp=sharing
https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete.ttf
```

To uninstall, remove the `powerline` package and then run:
`pip uninstall powerline`
The script also installs `python-pip` and `git` so if you don't need them you can remove them.

Then edit your `/etc/vim/vimrc` and `.bashrc` and remove the lines that the install script put there.
