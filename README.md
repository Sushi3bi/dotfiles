# dotfiles

- **Terminal**: [Ghostty](https://github.com/ghostty-org/ghostty)
- **Shell**: [Zsh](https://www.zsh.org) or [Nushell](https://www.nushell.sh)
- **Editor**: [NeoVim](https://neovim.io/) or [Zed](https://zed.dev)
- **Colorscheme**: [Tokyonight](https://github.com/folke/tokyonight.nvim)
- **Font**: [Monaspace Neon](https://github.com/githubnext/monaspace) from [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts)

## Setup

### Using Makefile (recommended)

```bash
# run interactive bootstrap
make bootstrap

# create/refresh symlinks
make link

# unlink then link
make relink

# remove symlinks created by this repo
make unlink

# brew bundle install/update and cleanup
make brew
make brew-clean

# apply macOS defaults
make macos

# rebuild bat theme cache (after linking)
make bat-cache
```

### Manual

```bash
./bootstrap
./dots
```

### Notes
- The dots script is idempotent and backs up replaced files under ~/.dotfiles_backup_YYYYmmddHHMMSS
- macOS-specific: bootstrap.macos applies system defaults; review before running
- Homebrew bundle uses homebrew/.Brewfile; mas requires App Store login
- Nushell optionally reads OPENAI_API_KEY and HOMEBREW_GITHUB_API_TOKEN from Keychain if present
- Zed agent model in settings.json assumes valid API access
- Git uses delta; themes auto-switch with macOS light/dark