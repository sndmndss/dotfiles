# dotfiles

## Structure

| Path | Symlink to |
|------|-----------|
| `zsh/zshrc` | `~/.zshrc` |
| `zsh/zprofile` | `~/.zprofile` |
| `zsh/zshenv` | `~/.zshenv` |
| `p10k.zsh` | `~/.p10k.zsh` |
| `gitconfig` | `~/.gitconfig` |
| `tmux/tmux.conf` | `~/.tmux.conf` |
| `nvim/` | `~/.config/nvim/` |
| `fish/config.fish` | `~/.config/fish/config.fish` |

## Requirements

### Core
```sh
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Shell
```sh
brew install zsh powerlevel10k
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# Install Nerd Font → https://www.nerdfonts.com (Symbols Nerd Font into ~/Library/Fonts)
```

### Terminal / multiplexer
```sh
brew install tmux
brew install --cask iterm2
# TPM (tmux plugin manager)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# then inside tmux: prefix + I  to install plugins
```

### Editor
```sh
brew install neovim
# Copy nvim/ → ~/.config/nvim then open nvim — lazy.nvim installs everything automatically
# LSP extras:
npm i -g typescript typescript-language-server
pip install pyright
rustup component add rust-analyzer
```

### Git tools
```sh
brew install git-lfs git-delta
git lfs install
brew install gnupg   # for GPG commit signing
```

### CLI essentials
```sh
brew install fzf ripgrep fd bat eza
```

## Symlinks

```sh
ln -sf ~/github/dotfiles/gitconfig       ~/.gitconfig
ln -sf ~/github/dotfiles/tmux/tmux.conf  ~/.tmux.conf
ln -sf ~/github/dotfiles/zsh/zshrc       ~/.zshrc
ln -sf ~/github/dotfiles/zsh/zprofile    ~/.zprofile
ln -sf ~/github/dotfiles/zsh/zshenv      ~/.zshenv
ln -sf ~/github/dotfiles/p10k.zsh        ~/.p10k.zsh
cp -r  ~/github/dotfiles/nvim            ~/.config/nvim
cp     ~/github/dotfiles/fish/config.fish ~/.config/fish/config.fish
```

## Secrets — create manually, never commit

```
~/.gitconfig.local   # name, email, signingkey (GPG key ID)
~/.npmrc             # npm auth token
~/.ssh/config        # SSH hosts & keys
```

### Environment variables (add to ~/.zshrc.local or export manually)

```sh
export GROQ_API_KEY="gsk_..."   # used by nvim/lua/custom/plugins/ai-descriptions.lua
```
