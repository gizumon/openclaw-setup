#!/bin/bash
set -euo pipefail

# システム更新と基本ツールのインストール
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl build-essential

# Node.js 24.x のインストール
curl -fsSL https://deb.nodesource.com/setup_24.x | sudo -E bash -
sudo apt install -y nodejs

# OpenClaw のインストール
sudo npm install -g openclaw@latest

# SSH ログイン時のメッセージを設定
sudo tee /etc/motd > /dev/null <<'EOF'

========================================
  OpenClaw セットアップ済み VM
========================================

【初回セットアップ】
  openclaw onboard --install-daemon

【Gateway の状態確認】
  openclaw gateway status

【Gateway の手動起動】
  openclaw gateway start

【Gateway の停止】
  openclaw gateway stop

========================================

EOF
