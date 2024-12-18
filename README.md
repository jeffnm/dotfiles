# dotfiles

## Chezmoi
This repo uses [chezmoi](https://www.chezmoi.io/) for most dotfile management

### Deployment
1. Install chezmoi
2. Run `chezmoi init git@github.com:jeffnm/dotfiles.git`
3. Answer any prompts (wallpaper paths for example)
4. Run `chezmoi status` to see which files will be effected.
5. Use `chezmoi diff <filename>` when needing to see what the difference between the source and target are. 
6. If there were issues, then use `chezmoi apply <filename>` or `<chezmoi re-add <filename>` or otherwise resolve the conflict.
7. If everything is good, run `chezmoi apply` to add all managed files from source. 

## Managed files
* alacritty
* helix/config.toml
* zshrc
* zimrc
* vimrc
* hypr/...
* mako
* waybar
* wofi

#### Unmaintained
I kept a copy of my xmonad config in `xmonad/` since it was the config that hooked me on tiling window managers. Eventually I'll delete it since I'm not going back to x11 again if I can help it.

#### ToDo
* improve templating for different systems
* find other unmanaged configs that could/should be added from each system
