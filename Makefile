# Makefile for dotfiles convenience commands

SHELL := /bin/bash
.DEFAULT_GOAL := help

# Ensure Homebrew in PATH for brew targets
export PATH := /opt/homebrew/bin:/opt/homebrew/sbin:$(PATH)

.PHONY: help link unlink relink brew brew-clean macos bootstrap bat-cache

help: ## Show this help (default target)
	@printf "Dotfiles commands:\n\n"
	@awk 'BEGIN {FS":.*## "; printf "%-14s %s\n", "Target", "Description"; printf "%-14s %s\n", "------", "-----------"} /^[a-zA-Z0-9_.-]+:.*## / { printf "%-14s %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

link: ## Create/refresh symlinks using ./dots
	@./dots

unlink: ## Remove symlinks created by this repo (only if they point to this repo)
	@set -euo pipefail; \
	DOTDIR="$$(pwd -P)"; \
	canonical_path() { \
	  if command -v perl >/dev/null 2>&1; then \
	    perl -MCwd -e 'print Cwd::abs_path(shift) // q{}' -- "$$1"; \
	  else \
	    ( cd "$$(dirname -- "$$1")" >/dev/null 2>&1 && printf '%s/%s' "$$(pwd -P)" "$$(basename -- "$$1")" ) || printf '%s' "$$1"; \
	  fi; \
	}; \
	while IFS=$$'\t' read -r src dst; do \
	  [ -n "$$src" ] || continue; \
	  # Expand ~ in destination
	  dst="$${dst/#\~/$${HOME}}"; \
	  if [ -L "$$dst" ]; then \
	    link_target="$$(readlink "$$dst" || true)"; \
	    if [ -z "$$link_target" ]; then continue; fi; \
	    if [[ "$$link_target" = /* ]]; then \
	      resolved_target="$$(canonical_path "$$link_target")"; \
	    else \
	      resolved_target="$$(canonical_path "$$(dirname "$$dst")/$$link_target")"; \
	    fi; \
	    resolved_src="$$(canonical_path "$$src")"; \
	    if [ -n "$$resolved_src" ] && [ -n "$$resolved_target" ] && [ "$$resolved_src" = "$$resolved_target" ]; then \
	      rm -f "$$dst"; \
	      printf "[UNLINK] %s\n" "$$dst"; \
	    fi; \
	  fi; \
	done <<EOF
$${DOTDIR}/.hammerspoon	$${HOME}/.hammerspoon
$${DOTDIR}/nushell/config.nu	$${HOME}/Library/Application Support/nushell/config.nu
$${DOTDIR}/nvim	$${HOME}/.config/nvim
$${DOTDIR}/bat	$${HOME}/.config/bat
$${DOTDIR}/btop	$${HOME}/.config/btop
$${DOTDIR}/zed	$${HOME}/.config/zed
$${DOTDIR}/ghostty	$${HOME}/.config/ghostty
$${DOTDIR}/gpg/gpg-agent.conf	$${HOME}/.gnupg/gpg-agent.conf
$${DOTDIR}/gpg/gpg.conf	$${HOME}/.gnupg/gpg.conf
$${DOTDIR}/git/ignore	$${HOME}/.config/git/ignore
$${DOTDIR}/git/themes.gitconfig	$${HOME}/.config/git/themes.gitconfig
$${DOTDIR}/git/.gitconfig	$${HOME}/.gitconfig
$${DOTDIR}/homebrew/.Brewfile	$${HOME}/.Brewfile
$${DOTDIR}/zsh/.zpath	$${HOME}/.zpath
$${DOTDIR}/zsh/.zprofile	$${HOME}/.zprofile
$${DOTDIR}/zsh/.zshenv	$${HOME}/.zshenv
$${DOTDIR}/zsh/.zshrc	$${HOME}/.zshrc
$${DOTDIR}/ssh/config	$${HOME}/.ssh/config
$${DOTDIR}/starship/starship.toml	$${HOME}/.config/starship.toml
EOF

relink: ## Unlink then link again (refresh all symlinks)
	@$(MAKE) --no-print-directory unlink
	@$(MAKE) --no-print-directory link

brew: ## Install/update Homebrew bundle from homebrew/.Brewfile
	@command -v brew >/dev/null 2>&1 || { echo "Homebrew not found in PATH"; exit 1; }
	@brew bundle --file=homebrew/.Brewfile

brew-clean: ## Remove unlisted Homebrew packages (cleanup)
	@command -v brew >/dev/null 2>&1 || { echo "Homebrew not found in PATH"; exit 1; }
	@brew bundle cleanup --file=homebrew/.Brewfile --force

macos: ## Apply macOS defaults from bootstrap.macos
	@/bin/sh ./bootstrap.macos

bootstrap: ## Run the interactive bootstrap script
	@/bin/sh ./bootstrap

bat-cache: ## Rebuild bat theme cache (run after linking themes)
	@command -v bat >/dev/null 2>&1 || { echo "bat not found in PATH"; exit 1; }
	@bat cache --build
