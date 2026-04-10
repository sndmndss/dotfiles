#!/usr/bin/env bash
# install.sh — bootstrap a new Mac from dotfiles
# Run: bash install.sh
set -euo pipefail

DOTFILES="$HOME/github/dotfiles"

# ── colours ───────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()  { echo -e "${GREEN}==> ${NC}$*"; }
warn()  { echo -e "${YELLOW}[!] ${NC}$*"; }
abort() { echo -e "${RED}[✗] ${NC}$*" >&2; exit 1; }

cmd() { command -v "$1" &>/dev/null; }

# ── 1. Xcode CLI tools ────────────────────────────────────────────────────────
step_xcode() {
  if xcode-select -p &>/dev/null; then
    info "Xcode CLI tools already installed"; return
  fi
  info "Installing Xcode CLI tools (follow the GUI prompt)..."
  xcode-select --install
  until xcode-select -p &>/dev/null; do sleep 5; done
  info "Xcode CLI tools ready"
}

# ── 2. Homebrew ───────────────────────────────────────────────────────────────
# https://brew.sh
step_homebrew() {
  if cmd brew; then
    info "Homebrew already installed"; return
  fi
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # add to PATH for the rest of this script
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"   # Apple Silicon
  elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"       # Intel
  fi
  info "Homebrew ready"
}

# ── 3. brew packages & casks ──────────────────────────────────────────────────
step_brew_packages() {
  info "Installing brew packages..."
  brew install \
    tmux \
    neovim \
    git-lfs \
    git-delta \
    gnupg \
    fzf \
    ripgrep \
    fd \
    bat \
    eza \
    node \
    python3

  info "Installing brew casks..."
  brew install --cask iterm2

  # Nerd Font (Symbols only — used by p10k and nvim icons)
  # Cask name from: https://github.com/ryanoasis/nerd-fonts#option-4-homebrew-fonts
  brew install --cask font-symbols-only-nerd-font

  info "Initialising git-lfs..."
  git lfs install
}

# ── 4. Oh My Zsh ──────────────────────────────────────────────────────────────
# https://ohmyz.sh/#install
step_omz() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    info "Oh My Zsh already installed"; return
  fi
  info "Installing Oh My Zsh..."
  # RUNZSH=no / CHSH=no keeps the script non-interactive
  RUNZSH=no CHSH=no \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  info "Oh My Zsh installed"
}

# ── 5. Powerlevel10k ──────────────────────────────────────────────────────────
# https://github.com/romkatv/powerlevel10k#oh-my-zsh
step_p10k() {
  local dest="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
  if [[ -d "$dest" ]]; then
    info "Powerlevel10k already installed"; return
  fi
  info "Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$dest"
  info "Powerlevel10k installed"
}

# ── 6. TPM — tmux plugin manager ──────────────────────────────────────────────
# https://github.com/tmux-plugins/tpm#installation
step_tpm() {
  if [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
    info "TPM already installed"; return
  fi
  info "Installing TPM..."
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  info "TPM installed — open tmux then press  prefix + I  to fetch plugins"
}

# ── 7. Rust / rustup ──────────────────────────────────────────────────────────
# https://www.rust-lang.org/tools/install
step_rust() {
  if cmd rustup; then
    info "Rust already installed"; return
  fi
  info "Installing Rust via rustup..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
  source "$HOME/.cargo/env"
  rustup component add rust-analyzer
  info "Rust installed"
}

# ── 8. NVM ────────────────────────────────────────────────────────────────────
# https://github.com/nvm-sh/nvm#installing-and-updating
# !! VERSION: update the tag below to the latest release before running !!
# Check current latest at: https://github.com/nvm-sh/nvm/releases
NVM_VERSION="v0.40.1"
step_nvm() {
  if [[ -d "$HOME/.nvm" ]]; then
    info "NVM already installed"; return
  fi
  warn "Installing NVM ${NVM_VERSION} — verify this is still the latest at https://github.com/nvm-sh/nvm/releases"
  curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
  info "NVM installed"
}

# ── 9. Bun ────────────────────────────────────────────────────────────────────
# https://bun.sh/docs/installation
step_bun() {
  if cmd bun; then
    info "Bun already installed"; return
  fi
  info "Installing Bun..."
  curl -fsSL https://bun.sh/install | bash
  info "Bun installed"
}

# ── 10. LSP tools (needs node from step 3) ────────────────────────────────────
step_lsp() {
  info "Installing LSP servers..."
  npm install -g typescript typescript-language-server pyright
  # rust-analyzer is installed as part of rustup in step_rust above
  info "LSP servers installed"
}

# ── 11. Symlinks ──────────────────────────────────────────────────────────────
make_link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ -L "$dst" ]]; then
    rm "$dst"
  elif [[ -e "$dst" ]]; then
    warn "Backing up $dst → $dst.bak"
    mv "$dst" "$dst.bak"
  fi
  ln -sf "$src" "$dst"
  info "  linked $dst"
}

step_symlinks() {
  info "Creating symlinks..."
  make_link "$DOTFILES/gitconfig"       "$HOME/.gitconfig"
  make_link "$DOTFILES/zsh/zshrc"       "$HOME/.zshrc"
  make_link "$DOTFILES/zsh/zprofile"    "$HOME/.zprofile"
  make_link "$DOTFILES/zsh/zshenv"      "$HOME/.zshenv"
  make_link "$DOTFILES/p10k.zsh"        "$HOME/.p10k.zsh"
  make_link "$DOTFILES/tmux/tmux.conf"  "$HOME/.tmux.conf"
}

# ── 12. Configs that live under ~/.config ─────────────────────────────────────
step_configs() {
  info "Copying configs to ~/.config..."
  mkdir -p "$HOME/.config"

  # nvim
  if [[ -d "$HOME/.config/nvim" && ! -L "$HOME/.config/nvim" ]]; then
    warn "Backing up ~/.config/nvim → ~/.config/nvim.bak"
    mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak"
  fi
  cp -r "$DOTFILES/nvim" "$HOME/.config/nvim"
  info "  nvim config copied"

  # fish
  mkdir -p "$HOME/.config/fish"
  cp "$DOTFILES/fish/config.fish" "$HOME/.config/fish/config.fish"
  info "  fish config copied"
}

# ── main ──────────────────────────────────────────────────────────────────────
main() {
  [[ -d "$DOTFILES" ]] || abort "Dotfiles not found at $DOTFILES — clone the repo first"

  step_xcode
  step_homebrew
  step_brew_packages
  step_omz
  step_p10k
  step_tpm
  step_rust
  step_nvm
  step_bun
  step_lsp
  step_symlinks
  step_configs

  echo ""
  info "All done. Manual steps remaining:"
  echo "  1.  Create ~/.gitconfig.local:"
  echo "        [user]"
  echo "          name       = Your Name"
  echo "          email      = you@example.com"
  echo "          signingkey = <GPG key ID>"
  echo "  2.  Import your GPG key:  gpg --import private.key"
  echo "  3.  Copy ~/.ssh/ keys (chmod 600 ~/.ssh/id_*)"
  echo "  4.  Open tmux → prefix + I  to install plugins"
  echo "  5.  Open nvim — lazy.nvim will auto-install plugins on first launch"
  echo "  6.  Run 'p10k configure' to re-run the prompt wizard (or it loads from p10k.zsh)"
  echo ""
  warn "Not installed by this script (install manually when needed):"
  echo "  - Anaconda / conda   https://www.anaconda.com/download"
  echo "  - Android SDK        via Android Studio"
  echo "  - Solana CLI         https://docs.solana.com/cli/install-solana-cli-tools"
  echo "  - JetBrains Toolbox  https://www.jetbrains.com/toolbox-app"
}

main "$@"
