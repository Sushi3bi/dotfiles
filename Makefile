# Makefile for dotfiles convenience commands

SHELL := /bin/bash
.DEFAULT_GOAL := help

# Ensure Homebrew in PATH for brew targets
export PATH := /opt/homebrew/bin:/opt/homebrew/sbin:$(PATH)

.PHONY: help link brew brew-clean macos bootstrap bat-cache

help: ## Show this help (default target)
	@printf "Dotfiles commands:\n\n"
	@awk 'BEGIN {FS":.*## "; printf "%-14s %s\n", "Target", "Description"; printf "%-14s %s\n", "------", "-----------"} /^[a-zA-Z0-9_.-]+:.*## / { printf "%-14s %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

link: ## Create/refresh symlinks using ./dots
	@./dots

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
