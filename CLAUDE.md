# public-pages

カスタムドメイン `hittsumi281.com` の GitHub Pages 静的サイト。
モバイルアプリ「日ぷらす（date-calc-app）」のプライバシーポリシーを公開しています。

- 公開 URL: https://hittsumi281.com/date-calc-app/privacy-policy/
- リポジトリ: `kclab281/public-pages`（branch: `main`）
- 配信: GitHub Pages（カスタムドメイン + HTTPS 強制）

## ディレクトリ

- `date-calc-app/privacy-policy/index.html` — プライバシーポリシー本体（編集対象）
- `CNAME` — カスタムドメイン定義（**触らない**）
- `.nojekyll` — Jekyll 無効化マーカー（**触らない**）

## 保護されているファイル

`CNAME` と `.nojekyll` は GitHub Pages のインフラ設定です。これらを書き換えると
カスタムドメインが外れたり、配信パイプラインが Jekyll に切り替わって表示が壊れます。

- Claude による Edit / Write / MultiEdit は `.claude/hooks/protect-pages-infra.sh` で
  ブロックされます（exit 2）。
- `permissions.deny` でも二重に拒否しています（`Edit(/CNAME)` `Write(/CNAME)` 等）。
- どうしても変更が必要な場合は人間が直接編集してコミットしてください。

## 公開コンテンツのルール

`date-calc-app/privacy-policy/index.html` は誰でも見られる公開ページです。

- 外部 JavaScript の追加・読み込みは行わない（追跡・解析スクリプトも禁止）。
- 個人を特定できる情報（実名・住所・電話番号など）を追加しない。連絡先は既存の
  メールアドレスのみ。
- 既存の制定日（2026-02-28）は履歴として保持。変更があれば改訂日を別途明記する。
- HTML を変更したら `xmllint --noout` 等で構文を確認してからコミット。

## Git ルール

- `force push` 禁止（`git push --force` / `-f` はすべて deny）。
- 履歴の書き換え禁止（`reset --hard` / `filter-branch` / `filter-repo` 等）。
- コミットメッセージは日本語で、既存スタイル（`feat:` / `fix:` / `chore:`）に揃える。

## GitHub Pages 設定（API）

Pages の設定は Claude からは **読み取り専用**：

- 読み取り（許可）: `gh api repos/kclab281/public-pages/pages`
- 書き込み（拒否）: `--method PUT/POST/PATCH/DELETE`、`-X PUT/...`、`-f`/`-F` で
  Pages エンドポイントを叩く操作すべて。
  設定変更は GitHub の Web UI または人間の手元で行ってください。

## Claude Code 設定

- `defaultMode`: `plan`（プラン承認まで編集は走らない）
- 設定: `.claude/settings.json`（コミット対象、`settings.local.json` は使わない）
- フック: `.claude/hooks/protect-pages-infra.sh`（PreToolUse で CNAME/.nojekyll をブロック）
