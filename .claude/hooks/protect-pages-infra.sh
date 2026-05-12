#!/usr/bin/env bash
# protect-pages-infra.sh
# PreToolUse hook: block Edit / Write / MultiEdit against
# GitHub Pages infrastructure files (CNAME, .nojekyll).
#
# Exit 2 + stderr message => Claude Code blocks the tool call and shows the message.

set -euo pipefail

input="$(cat)"

if command -v jq >/dev/null 2>&1; then
  tool_name="$(printf '%s' "$input" | jq -r '.tool_name // empty')"
  file_path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')"
else
  tool_name="$(printf '%s' "$input" | sed -n 's/.*"tool_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)"
  file_path="$(printf '%s' "$input" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)"
fi

case "${tool_name:-}" in
  Edit|Write|MultiEdit) ;;
  *) exit 0 ;;
esac

[ -z "${file_path:-}" ] && exit 0

project_dir="${CLAUDE_PROJECT_DIR:-$PWD}"
basename_path="$(basename -- "$file_path")"

is_protected=0
case "$basename_path" in
  CNAME|.nojekyll)
    if [ "${file_path#/}" = "$file_path" ]; then
      abs_path="$project_dir/$file_path"
    else
      abs_path="$file_path"
    fi
    abs_path="$(printf '%s' "$abs_path" | sed 's|/\./|/|g; s|^\./||')"

    if [ "$abs_path" = "$project_dir/CNAME" ] || \
       [ "$abs_path" = "$project_dir/.nojekyll" ] || \
       [ "$file_path" = "CNAME" ] || \
       [ "$file_path" = ".nojekyll" ] || \
       [ "$file_path" = "./CNAME" ] || \
       [ "$file_path" = "./.nojekyll" ]; then
      is_protected=1
    fi
    ;;
esac

if [ "$is_protected" -eq 1 ]; then
  cat >&2 <<EOF
[protect-pages-infra] BLOCKED: $tool_name on '$file_path'

CNAME と .nojekyll は GitHub Pages のインフラ設定ファイルです。
  - CNAME はカスタムドメイン (hittsumi281.com) を固定します。
  - .nojekyll は Jekyll 処理を無効化します。

これらを Claude 経由で変更することはリポジトリポリシーで禁止されています。
本当に変更が必要な場合は人間が直接編集してください:

  \$ \$EDITOR CNAME
  \$ git add CNAME && git commit -m "chore: update CNAME"

詳細は CLAUDE.md 「保護されているファイル」を参照。
EOF
  exit 2
fi

exit 0
