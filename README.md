# dotfiles

Personal shell and terminal setup for macOS and Linux.

## What `setup.sh` does

- Bootstraps core dependencies such as `git`, `curl`, `zsh`, `tmux`, `fzf`, Starship, zsh plugins, and tmux TPM.
- Installs Homebrew only on macOS.
- Symlinks tracked config into `$HOME`.
- On Linux, tries to switch the default shell to `zsh` and falls back to a `~/.bashrc` handoff when `chsh` is not usable.

## Safety

- Existing real files are backed up to `*.bak.<timestamp>` before being replaced.
- Existing generated zsh artifacts inside the repo are cleaned up during setup.
- Generated zsh state now lives outside the repo:
  - completion dump: `${XDG_CACHE_HOME:-$HOME/.cache}/zsh`
  - history: `${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history`

## Install

```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
./setup.sh
```

## Notes

- macOS setup also installs `aerospace`, `ghostty`, and `karabiner-elements`.
- If you do not want the Linux shell-switch step, run with `DOTFILES_SKIP_CHSH=1`.
- If Homebrew is already installed on Linux, the bootstrap script can still use it for package installs, but it will not install it for you.
