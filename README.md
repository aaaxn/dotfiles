<div align="center">
<img src="1.jpg" width="600" title="art by @lvl374"/>
</div>

## Setup

```sh
git clone https://github.com/aaaxn/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./setup.sh
```

Installs dependencies (oh-my-zsh, Pure prompt, zsh plugins, tmux + tpm) and
symlinks the configs. Safe to re-run; existing files are backed up, not
overwritten.

- **Everywhere:** zsh (oh-my-zsh + Pure), tmux, gitmux
- **macOS only:** Ghostty, AeroSpace, Karabiner (Caps Lock → Hyper)
- **Linux only:** sets zsh as the default shell
