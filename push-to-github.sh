#!/bin/bash
# Run this after creating the repo at https://github.com/new (name: Timer-FlashLight, Public)
# Replace YOUR_GITHUB_USERNAME with your actual GitHub username.

USERNAME="${1:-YOUR_GITHUB_USERNAME}"
if [ "$USERNAME" = "YOUR_GITHUB_USERNAME" ]; then
  echo "Usage: ./push-to-github.sh YOUR_GITHUB_USERNAME"
  echo "Example: ./push-to-github.sh nibir"
  exit 1
fi

cd "$(dirname "$0")"
git remote add origin "https://github.com/${USERNAME}/Timer-FlashLight.git" 2>/dev/null || git remote set-url origin "https://github.com/${USERNAME}/Timer-FlashLight.git"
git branch -M main
git push -u origin main
echo "Done! Repo: https://github.com/${USERNAME}/Timer-FlashLight"
