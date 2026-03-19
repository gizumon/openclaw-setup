# OpenClaw セットアップガイド

## 方法 1：ローカル PC へのインストール

Node.js 22 以上が必要です。

```bash
npm install -g openclaw@latest
openclaw onboard --install-daemon
openclaw gateway status
```

> **注意：** OpenClaw は AI エージェントです。ローカル PC で直接動かすと、ファイルの誤削除・機密情報の漏洩・リソース圧迫などのリスクがあります。

---

## 方法 2：GCP 仮想マシンへのインストール（推奨）

ローカル環境に影響を与えない、完全に隔離された環境で動かします。

### 事前準備

1. [Google Cloud Console](https://console.cloud.google.com/) でプロジェクトを作成し、**プロジェクト ID** をメモ
2. 「お支払い」から請求先アカウントをリンク（新規なら $300 無料クレジットあり）
3. ローカル PC に gcloud CLI と Terraform をインストール

```bash
brew install --cask google-cloud-sdk
brew tap hashicorp/tap && brew install hashicorp/tap/terraform
```

### VM の構築

```bash
gcloud auth application-default login

cd infra
cp terraform.tfvars.example terraform.tfvars
# terraform.tfvars を編集して project_id を設定

terraform init
terraform apply
```

### VM への接続

```bash
gcloud compute ssh openclaw-vm \
    --zone=asia-northeast1-b \
    --tunnel-through-iap \
    --project=YOUR_PROJECT_ID
```

### VM 内でのセットアップ

VM に接続すると、startupスクリプトが自動でNode.js と OpenClaw をインストールします。
完了までしばらく待つ必要があります。以下のコマンドで進捗を確認してください。

```bash
# startupスクリプトの完了を監視（完了したら Ctrl+C）
sudo journalctl -u google-startup-scripts.service -f
```

完了したら初期設定を実行します。

```bash
openclaw onboard --install-daemon
openclaw gateway status
```

### 環境の削除（課金停止）

```bash
cd infra
terraform destroy
```

---

## Gemini API キーの発行

1. [Google AI Studio](https://aistudio.google.com/) にアクセス
2. 左メニュー「Get API key」→「APIキーを作成」
3. 表示されたキーをコピーして `openclaw onboard` 実行時に入力

---

## Slackワークスペースへの接続

下記を参考に、OpenClaw を Slack ワークスペースに接続してください。

* https://zenn.dev/hisamitsu/articles/2da15f23f68020
* https://note.com/aihigememo/n/nb273fcb423a0
* https://zenn.dev/and_dot/articles/a3c7e1f9b02d48

基本的には、下記の手順が必要です。
* Slack API で適切な権限を付与してアプリを作成
* 発行した Bot User OAuth Token と App Token を OpenClaw に設定
* OpenClawをワークスペースにインストールし、OpenClawにメンション
* OpenClaw側でPairingを完了