#!/bin/zsh
set -e

#
# INSTALLING TOOLS + PODMAN ON A MAC MINI SERVER.
#

# Homebrew
if ! command -v brew >/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Persist Homebrew in zsh
if ! grep -Fq 'brew shellenv' "$HOME/.zprofile" 2>/dev/null; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
fi

eval "$(/opt/homebrew/bin/brew shellenv)"

# Packages
brew install wget git python podman podman-desktop cloudflared

# Git defaults
git config --global init.defaultBranch main

# Make Podman's API available through the standard Docker socket
PODMAN_MAC_HELPER="$(brew --prefix podman)/bin/podman-mac-helper"
ls -l "$PODMAN_MAC_HELPER"
sudo "$PODMAN_MAC_HELPER" install

# Podman machine
podman machine init \
    --provider applehv \
    --cpus 6 \
    --memory 8192 \
    --disk-size 100
podman machine start

echo "Done."
echo "Git:    $(git --version)"
echo "Python: $(python3 --version)"
echo "Brew:   $(brew --version | head -1)"
podman ps
ls -l /var/run/docker.sock
