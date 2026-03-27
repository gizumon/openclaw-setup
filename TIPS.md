# Tips

後で使えるコマンド集。

## GCE インスタンスへの接続

### SSH アクセス（IAP経由）

```bash
export PROJECT_ID="your-project-id"
export ZONE="asia-northeast1-b"

gcloud compute ssh "${INSTANCE_NAME}" \
  --zone="${ZONE}" \
  --tunnel-through-iap \
  --project="${PROJECT_ID}"
```

### Port Forward（IAP経由）

ローカルポートにフォワードして `http://localhost:${PORT}` でアクセスできる。

```bash
export PROJECT_ID="gizumon-agents"
export PORT=18789
export INSTANCE_NAME="openclaw-vm"
export ZONE="asia-northeast1-b"
gcloud compute ssh "${INSTANCE_NAME}" \
  --zone="${ZONE}" \
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

## Control UI assets not found エラーの対処

```bash
sudo su root
npm install -g openclaw@2026.3.13
openclaw gateway stop
openclaw gateway install
```

## GCE 外部アクセス設定

### VMの外部IPを確認する

```bash
gcloud compute instances describe openclaw-vm \
  --zone="${ZONE}" \
  --project="${PROJECT_ID}" \
  --format="get(networkInterfaces[0].accessConfigs[0].natIP)"
```

外部IPが付与されていれば `http://${EXTERNAL_IP}:8080` でアクセスできる。

## Terraform

```bash
# 初回セットアップ
cd infra
terraform init
terraform apply

# 環境削除（課金停止）
terraform destroy
```

### 複数インスタンスの起動

`locals.tf` の `instances` マップにエントリを追加する。キーがインスタンス名になり、`machine_type` をインスタンスごとに設定できる。

```hcl
# infra/locals.tf
locals {
  instances = {
    "openclaw-vm" = {
      machine_type = "e2-standard-2"
    }
    "openclaw-vm-2" = {
      machine_type = "e2-standard-2"
    }
    # 追加したい場合はここにエントリを足す
  }
}
```

```bash
terraform apply
```

`terraform apply` 後、各インスタンスの名前と外部IPがマップ形式で出力される。
