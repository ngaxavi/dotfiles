#!/bin/bash

# SSH and GPG Key Generation Script for GitHub/GitLab 

set -e

echo "=========================================="
echo "SSH & GPG Key Generation Script"
echo "=========================================="
echo ""

# ===============================
# SSH KEY SETUP
# ===============================
echo ""
echo "📦 Creating SSH key with passphrase..."

read -p "➡️  Your email for SSH key: " SSH_EMAIL
read -s -p "🔑 Enter SSH key passphrase (leave blank for none): " SSH_PASSPHRASE
echo ""
SSH_KEY_PATH="$HOME/.ssh/id_ed25519"

if [ -f "$SSH_KEY_PATH" ]; then
  echo "⚠️  SSH key already exists at $SSH_KEY_PATH"
else
  ssh-keygen -t ed25519 -C "$SSH_EMAIL" -f "$SSH_KEY_PATH" -N "$SSH_PASSPHRASE"
  echo "✅ SSH key created!"
fi

eval "$(ssh-agent -s)"
ssh-add "$SSH_KEY_PATH"

SSH_PUB_KEY=$(cat "${SSH_KEY_PATH}.pub")

# ===============================
# GPG KEY SETUP
# ===============================
echo ""
echo "📦 Creating GPG key with passphrase..."

read -p "➡️  Your full name (for GPG): " GPG_NAME
read -p "➡️  Your email (for GPG): " GPG_EMAIL
read -s -p "🔑 Enter GPG passphrase (leave blank for none): " GPG_PASSPHRASE
echo ""

cat > genkey.txt <<EOF
Key-Type: default
Key-Length: 4096
Subkey-Type: default
Name-Real: $GPG_NAME
Name-Email: $GPG_EMAIL
Expire-Date: 0
Passphrase: $GPG_PASSPHRASE
%commit
%echo done
EOF

gpg --batch --gen-key genkey.txt
rm genkey.txt

GPG_KEY_ID=$(gpg --list-secret-keys --keyid-format LONG "$GPG_EMAIL" | grep sec | awk '{print $2}' | cut -d'/' -f2)
GPG_PUB_KEY=$(gpg --armor --export "$GPG_KEY_ID")

echo "✅ GPG key created: $GPG_KEY_ID"


# ===============================
# GIT CONFIGURATION
# ===============================
echo ""
echo "🧩 Configuring Git..."

git config --global user.name "$GPG_NAME"
git config --global user.email "$GPG_EMAIL"
git config --global user.signingkey "$GPG_KEY_ID"
git config --global commit.gpgsign true
git config --global color.ui always
git config --global core.editor nvim

echo "✅ Git configured for signed commits"

# ===============================
# UPLOAD OPTIONS
# ===============================
echo ""
echo "🌐 Choose upload option:"
echo "1) GitHub"
echo "2) GitLab"
echo "3) Both"
echo "4) Skip upload"
read -p "➡️  Select option [1-4]: " CHOICE

case $CHOICE in
  1)
    TARGETS=("GitHub")
    ;;
  2)
    TARGETS=("GitLab")
    ;;
  3)
    TARGETS=("GitHub" "GitLab")
    ;;
  4)
    echo "🚫 Skipping upload."
    TARGETS=()
    ;;
  *)
    echo "❌ Invalid option. Skipping upload."
    TARGETS=()
    ;;
esac

for PLATFORM in "${TARGETS[@]}"; do
  echo ""
  echo "⬆️  Uploading to $PLATFORM..."

  if [ "$PLATFORM" = "GitHub" ]; then
    read -p "🔑 GitHub Personal Access Token: " GITHUB_TOKEN
    read -p "📛 SSH key title (e.g. Laptop, Work-PC): " SSH_TITLE

    echo "➡️  Uploading SSH key to GitHub..."
    curl -s -X POST -H "Authorization: token $GITHUB_TOKEN" \
      -d "{\"title\":\"$SSH_TITLE\",\"key\":\"$SSH_PUB_KEY\"}" \
      https://api.github.com/user/keys \
      | grep -E '"id"|message'

    echo "➡️  Uploading GPG key to GitHub..."
    curl -s -X POST -H "Authorization: token $GITHUB_TOKEN" \
      -H "Content-Type: application/json" \
      -d "{\"armored_public_key\":\"$GPG_PUB_KEY\"}" \
      https://api.github.com/user/gpg_keys \
      | grep -E '"id"|message'

    echo "✅ Keys uploaded to GitHub."

  elif [ "$PLATFORM" = "GitLab" ]; then
    read -p "🔑 GitLab Personal Access Token: " GITLAB_TOKEN
    read -p "🌐 GitLab URL (default: https://gitlab.com): " GITLAB_URL
    GITLAB_URL=${GITLAB_URL:-https://gitlab.com}
    read -p "📛 SSH key title (e.g. Laptop, Work-PC): " SSH_TITLE

    echo "➡️  Uploading SSH key to GitLab..."
    curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
      --data-urlencode "title=$SSH_TITLE" \
      --data-urlencode "key=$SSH_PUB_KEY" \
      "$GITLAB_URL/api/v4/user/keys" \
      | grep -E '"id"|message'

    echo "➡️  Uploading GPG key to GitLab..."
    curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
      --data-urlencode "key=$GPG_PUB_KEY" \
      "$GITLAB_URL/api/v4/user/gpg_keys" \
      | grep -E '"id"|message'

    echo "✅ Keys uploaded to GitLab."
  fi
done


echo ""
echo "🎉 All done!"
echo "👉 Test SSH: ssh -T git@github.com"
echo "👉 Test GPG: git commit -S -m 'test'"