#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local path="$1"
  local expected="$2"

  grep -Fq -- "$expected" "${REPO_ROOT}/${path}" || fail "${path} missing: ${expected}"
}

issue2task_files=(
  "skills/codev-issue2task/SKILL.md"
  "skills/codev-issue2task/agents/openai.yaml"
  "docs/skills/codev-issue2task.md"
)

for path in "${issue2task_files[@]}"; do
  assert_contains "$path" "<subdir>#70"
  assert_contains "$path" "子目录"
  assert_contains "$path" "目标仓库"
done

assert_contains "skills/codev-issue2task/SKILL.md" "所有带子目录前缀的 issue 引用必须指向同一个子目录"
assert_contains "docs/skills/codev-issue2task.md" '$codev-issue2task <subdir>#70'
assert_contains "skills/codev-issue2task/agents/openai.yaml" "<subdir>#70"

echo "issue2task input rules checks passed"
