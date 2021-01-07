To automaticall install zsh, oh-my-zsh, and activate git, syntax highlithting, and autocompletion plugins, run the following line:
```
sh -c "$(wget https://gitlab.com/k-caps/scripts/-/raw/master/linux/zsh/config_zsh.sh -O -)"
```
During the script's run, you will be asked if you want to set zsh as your default shell. Press <kbd>enter</kbd>, and you will be dropped into a zsh prompt. Press <kbd>ctrl</kbd> + <kbd>d</kbd> to get back into the previous shell to continue the script's run, which will end with an interactive dialog helping you configure your p10k prompts. If you want to use mine, quit the interactive dialog by pressing <kbd>q</kbd> and run the following command:  
```
curl https://gitlab.com/k-caps/linux-scripts/-/raw/master/p10k.zsh | sed "s|/home/kobi|$HOME|g"  > ~/.zshrc
```

More information and screenshots can be found on my [medium blog](https://medium.com/for-linux-users/my-linux-terminal-setup-d10b28d0ce84)



