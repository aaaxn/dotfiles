# Dotfiles

Configurações essenciais organizadas seguindo a estrutura do `$HOME`.

## Estrutura
```
.
├── config
│   ├── starship.toml
│   └── tmux
│       ├── tmux.conf
│       └── scripts
├── home
│   ├── .gitconfig
│   ├── .tmux.conf
│   ├── .zshenv
│   ├── .zsh_plugins.txt
│   └── .zshrc
└── scripts
    ├── bootstrap.sh
    └── install.sh
```

## Instalação (manual)
```bash
# no $HOME
ln -sfn ~/dotfiles/home/.zshrc ~/.zshrc
ln -sfn ~/dotfiles/home/.zshenv ~/.zshenv
ln -sfn ~/dotfiles/home/.zsh_plugins.txt ~/.zsh_plugins.txt
ln -sfn ~/dotfiles/home/.tmux.conf ~/.tmux.conf
ln -sfn ~/dotfiles/home/.gitconfig ~/.gitconfig

mkdir -p ~/.config
ln -sfn ~/dotfiles/config/starship.toml ~/.config/starship.toml
ln -sfn ~/dotfiles/config/tmux ~/.config/tmux
```

## Instalação (automática)
```bash
~/dotfiles/scripts/install.sh
```

## Bootstrap (dependências)
```bash
~/dotfiles/scripts/bootstrap.sh
```

Notas:
- Quando houver dúvida de gerenciador, o script prioriza `brew` (e tenta `bun` apenas se aplicável), depois usa o gerenciador do sistema.
- O bootstrap também instala o Homebrew e o `fzf`.

## Observações
- O TPM (tmux plugin manager) deve estar em `~/.tmux/plugins/tpm`.
- `~/.zsh_plugins.zsh` é gerado pelo Antidote; mantenha apenas o `.zsh_plugins.txt` versionado.
