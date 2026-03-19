# Tips

後で使えるコマンド集。

## GCE インスタンスへの接続

### SSH アクセス（IAP経由）

```bash
PROJECT_ID="your-project-id"

gcloud compute ssh openclaw-vm \
  --zone=asia-northeast1-b \
  --tunnel-through-iap \
  --project="${PROJECT_ID}"
```

### Port Forward（IAP経由）

ローカルポートにフォワードして `http://localhost:${PORT}` でアクセスできる。

```bash
PROJECT_ID="your-project-id"
PORT=18789

# VMの${PORT}番をlocalhost:${PORT}にフォワード
gcloud compute ssh openclaw-vm \
  --zone=asia-northeast1-b \
  --tunnel-through-iap \
  --project="${PROJECT_ID}" \
  -- -L "${PORT}:localhost:${PORT}" -N
```

フォワードしたまま別ターミナルで `http://localhost:${PORT}` にアクセス。終了は `Ctrl+C`。

### startup-script の実行ログ確認

VM接続後、セットアップ完了を待つときに使う。

```bash
sudo journalctl -u google-startup-scripts.service -f
```

## Terraform

```bash
# 初回セットアップ
cd infra
terraform init
terraform apply

# 環境削除（課金停止）
terraform destroy
```
