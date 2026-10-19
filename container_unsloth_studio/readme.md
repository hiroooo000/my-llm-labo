# Unsloth Studio on NVIDIA DGX Spark

NVIDIA DGX Spark（Grace Blackwell GB10 / aarch64）環境向けの **Unsloth Studio** コンテナ実行環境です。

ベースイメージ `unsloth-dgx-spark:latest`（NGC PyTorch 25.11, CUDA 13.0, Blackwell 最適化版 Triton / xformers）の依存関係を維持したまま、最新の Unsloth Studio Web UI を安全に実行できます。

---

## ファイル構成

| ファイル | 説明 |
| :--- | :--- |
| `Dockerfile` | 最新の Unsloth Studio 環境を構築する Dockerfile |
| `config.sh` | コンテナ名・イメージ名などの共通環境変数定義 |
| `start_container.sh` | イメージのビルドおよびコンテナの起動スクリプト（`--rebuild` 対応） |
| `stop_container.sh` | 起動中コンテナの停止スクリプト |
| `update_container.sh` | Unsloth / Unsloth Studio を安全に最新化するアップデートスクリプト |
| `connect_container.sh` | 稼働中コンテナの bash シェルへ接続するスクリプト |
| `readme.md` | 本説明ドキュメント |

---

## 前提条件

1. **ベースイメージの準備**:
   本イメージは `unsloth-dgx-spark:latest` をベースにしています。まだ作成されていない場合は、先に `container_unsloth` ディレクトリにてビルドを行ってください。
   ```bash
   cd ../container_unsloth
   ./start_container.sh
   cd ../container_unsloth_studio
   ```
2. **NVIDIA GPU Passthrough**:
   NVIDIA Container Toolkit が正しくセットアップされていること。

---

## 使い方

### 1. コンテナのビルド & 起動

以下のコマンドを実行すると、Docker イメージのビルドとコンテナの起動がバックグラウンドで行われます。

```bash
./start_container.sh
```

- 既存の同名コンテナが存在する場合は自動で削除・再作成されます。
- Unsloth Studio がポート `8888` で起動します。

### 2. Web UI へのアクセス

ブラウザから以下のアドレスにアクセスします：

```text
http://<DGX-SparkのIPまたはホスト名>:8888
```

> **Note**: SSH ポートフォワード（トンネル）を使用している場合（例: `ssh -L 8888:localhost:8888 ...`）は、ローカルブラウザから `http://localhost:8888` でアクセスできます。

### 3. ログの確認

起動時のステータスやサーバーログを確認したい場合は、以下のコマンドを実行します：

```bash
docker logs -f unsloth-studio-dgx-spark
```

### 4. コンテナ内のシェルに接続

コンテナ内で直接コマンドを実行したり環境を確認したい場合は、`connect_container.sh` を使用します：

```bash
./connect_container.sh
```

### 5. コンテナの停止

コンテナを停止する場合は、以下のスクリプトを実行します：

```bash
./stop_container.sh
```

### 6. Unsloth Studio のアップデート

本環境では、**コンテナ起動時に毎回自動で Unsloth および Audio runtime の最新バージョンをチェック・更新して起動**するよう構成されています。

#### ① 通常起動時の自動アップデート（デフォルト動作）
通常どおり以下の起動スクリプトを実行するだけで、コンテナ起動時に自動で最新パッケージが取得・適用されて起動します。

```bash
./start_container.sh
```

- 起動時に `pip install --no-cache-dir -U --no-deps unsloth unsloth_zoo` および `audio.cpp` の更新が自動実行されます。
- 万が一ネットワークが不安定な場合でも、エラーで起動が停止しないようフォールバック設計になっています。

#### ② 稼働中のコンテナを即座に最新化する場合
コンテナを停止・再作成せず、稼働したままバックグラウンドで最新化したい場合は、アップデートスクリプトを実行します（所要時間: 数十秒）：

```bash
./update_container.sh
```

- **GitHub main ブランチの最新開発版へ更新する場合**:
  ```bash
  ./update_container.sh --git
  ```
- **特定バージョンを指定する場合**:
  ```bash
  ./update_container.sh --version 2026.10.7
  ```

> **重要 (Blackwell 依存関係の保護)**: すべての更新処理は内部で `--no-deps` を付与して行われるため、DGX Spark 向けに事前ビルドされた NGC PyTorch 25.11 や Blackwell 最適化版 Triton / xformers が PyPI の汎用 wheel で上書き破壊されることはありません。

#### ③ Docker イメージをゼロから完全再構築する場合
```bash
./start_container.sh --rebuild
```

---

## データ永続化とボリュームマウント

`start_container.sh` では以下のホストディレクトリがマウントされ、データが永続化されます：

- **作業ディレクトリ**: `$(pwd):$(pwd)`（実行時のカレントディレクトリ）
- **Hugging Face キャッシュ**: `$HOME/.cache/huggingface` -> `/root/.cache/huggingface`
- **Studio ワークスペース・設定**: `$HOME/.unsloth/studio` -> `/root/.unsloth/studio`
- **Audio ランタイム & モデル**: `$HOME/.unsloth/audio.cpp` -> `/root/.unsloth/audio.cpp`

> **Note**: ホスト側の `$HOME/.unsloth/studio` が空の状態でマウントされた場合でも、コンテナ起動時のエントリーポイントスクリプト（`entrypoint.sh`）により、イメージ内から必要なシステム設定ファイルが自動復元されます。また、Audio ランタイム（audio.cpp）もホスト側に永続化されます。

---

## DGX Spark (Blackwell GB10) 向けの最適化

- **専用仮想環境の継承 (`--system-site-packages`)**:
  ベースイメージに含まれる NGC PyTorch 25.11、ソースビルドされた Blackwell 対応 Triton / xformers をそのまま継承しつつ、Studio バックエンドに必要な FastAPI / uvicorn / typer 等を安全に追加しています。
- **GB10 メモリ検出対応**:
  NVIDIA GB10 のユニファイドメモリ環境において `nvidia-smi` がメモリ使用量に `[N/A]` を返す挙動に対応し、GPU 認識が正しく行われるようになっています。
