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

assert_not_contains() {
  local path="$1"
  local unexpected="$2"

  if grep -Fq -- "$unexpected" "${REPO_ROOT}/${path}"; then
    fail "${path} still contains: ${unexpected}"
  fi
}

quickship_files=(
  "skills/codev-quickship/SKILL.md"
  "skills/codev-quickship/agents/openai.yaml"
  "docs/skills/codev-quickship.md"
)

checkpoint_files=(
  "skills/codev-checkpoint/SKILL.md"
  "skills/codev-checkpoint/agents/openai.yaml"
  "docs/skills/codev-checkpoint.md"
)

for path in "${quickship_files[@]}"; do
  assert_contains "$path" "未显式指定版本"
  assert_contains "$path" "最后一位加一"
done

for path in "${checkpoint_files[@]}"; do
  assert_contains "$path" "最后一位加一"
done

assert_contains "README.md" "quickship 默认把最后一位加一"
assert_contains "README.md" 'checkpoint 默认会同步根目录 `VERSION` 与 `CHANGELOG`'
assert_contains "docs/workflows/README.md" "quickship 默认把最后一位加一"
assert_contains "docs/workflows/README.md" '默认把第 4 位加一'
assert_contains "AGENTS.md" "quickship 在未显式指定版本时默认把最后一位加一"
assert_contains "AGENTS.md" "checkpoint 在未显式指定目标版本时默认把第 4 位加一"

assert_not_contains "skills/codev-quickship/SKILL.md" "第 3 位加一"
assert_not_contains "skills/codev-quickship/SKILL.md" "第 4 位重置为 0"
assert_not_contains "docs/skills/codev-quickship.md" "第 3 位加一"
assert_not_contains "docs/skills/codev-quickship.md" "第 4 位重置为 0"
assert_not_contains "skills/codev-checkpoint/SKILL.md" "只有用户明确要求同步版本时"
assert_not_contains "docs/skills/codev-checkpoint.md" "如果用户明确要求同步版本"

echo "version rules checks passed"
