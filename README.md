# Dotfiles

Configurações essenciais organizadas seguindo a estrutura do `$HOME`.

## Estrutura
```
.
├── .config
│   ├── starship.toml
│   └── tmux
│       ├── tmux.conf
│       └── scripts
├── .tmux.conf
├── .zshenv
├── .zsh_plugins.txt
└── .zshrc
```

## Instalação (manual)
```bash
# no $HOME
ln -sfn ~/dotfiles/.zshrc ~/.zshrc
ln -sfn ~/dotfiles/.zshenv ~/.zshenv
ln -sfn ~/dotfiles/.zsh_plugins.txt ~/.zsh_plugins.txt
ln -sfn ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -sfn ~/dotfiles/.gitconfig ~/.gitconfig

mkdir -p ~/.config
ln -sfn ~/dotfiles/.config/starship.toml ~/.config/starship.toml
ln -sfn ~/dotfiles/.config/tmux ~/.config/tmux
```

## Instalação (automática)
```bash
~/dotfiles/install.sh
```

## Bootstrap (dependências)
```bash
~/dotfiles/bootstrap.sh
```

Notas:
- Quando houver dúvida de gerenciador, o script prioriza `brew` (e tenta `bun` apenas se aplicável), depois usa o gerenciador do sistema.

## Observações
- O TPM (tmux plugin manager) deve estar em `~/.tmux/plugins/tpm`.
- `~/.zsh_plugins.zsh` é gerado pelo Antidote; mantenha apenas o `.zsh_plugins.txt` versionado.
