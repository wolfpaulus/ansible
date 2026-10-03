#!/bin/zsh
set -e

#
# INSTALLING TOOLS + COLIMA ON A MAC MINI SERVER.
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
brew install wget git python colima docker docker-compose docker-buildx cloudflared

# Git defaults
git config --global init.defaultBranch main

# Colima
mkdir -p ~/.docker/cli-plugins

ln -sfn "$(brew --prefix)/opt/docker-compose/bin/docker-compose" \
  ~/.docker/cli-plugins/docker-compose

ln -sfn "$(brew --prefix)/opt/docker-buildx/bin/docker-buildx" \
  ~/.docker/cli-plugins/docker-buildx

colima start \
  --cpu 6 \
  --memory 8 \
  --disk 100 \
  --arch aarch64 \
  --runtime docker \
  --vm-type vz \
  --mount-type virtiofs \
  --mount-inotify \
  --dns 1.1.1.1 \
  --dns 1.0.0.1

brew services start colima

echo "Done."
echo "Git:    $(git --version)"
echo "Python: $(python3 --version)"
echo "Brew:   $(brew --version | head -1)"
brew services list
colima status -e
docker ps


