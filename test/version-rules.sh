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

assert_not_matches() {
  local path="$1"
  local pattern="$2"

  if grep -Eq -- "$pattern" "${REPO_ROOT}/${path}"; then
    fail "${path} still matches regex: ${pattern}"
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

version_surface_files=(
  "README.md"
  "AGENTS.md"
  "memory/core/invariants.md"
  "CHANGELOG"
  "${quickship_files[@]}"
  "${checkpoint_files[@]}"
)

legacy_digit_label="4""位"
legacy_cn_label="四""位"
legacy_example="x.y.z.""w"
legacy_commit_example="vX.Y.Z.""W"
legacy_numeric_regex='([0-9]+\.){3}[0-9]+'

for path in "${quickship_files[@]}"; do
  assert_contains "$path" "未显式指定版本"
  assert_contains "$path" "vX.Y.Z"
  assert_contains "$path" "补丁位加一"
  assert_contains "$path" "无 task"
  assert_contains "$path" "CHANGELOG"
  assert_contains "$path" "X.Y.Z"
done

for path in "${checkpoint_files[@]}"; do
  assert_contains "$path" "VERSION"
  assert_contains "$path" "CHANGELOG"
  assert_contains "$path" "X.Y.Z"
done

assert_contains "README.md" 'quickship 默认递增 `VERSION` 的补丁位'
assert_contains "README.md" "如果仓库没有 task，也可以按无 task 模式收尾"
assert_contains "README.md" '有 task 时默认沿用 `codev-taskdev` 已完成的默认 build'
assert_contains "README.md" 'checkpoint 不再默认同步根目录 `VERSION` 与 `CHANGELOG`'
assert_contains "docs/workflows.md" "codev-quickship"
assert_contains "docs/workflows.md" "codev-checkpoint"
assert_contains "docs/workflows.md" "如果仓库没有 task，也可按无 task 模式收尾"
assert_contains "docs/workflows.md" '`codev-taskdev` 负责代码实现、任务文档同步，以及一次实现收尾精简和默认 build / 最小编译校验'
assert_contains "AGENTS.md" 'quickship 在未显式指定版本时默认把 `VERSION` 的补丁位加一'
assert_contains "AGENTS.md" "若仓库里没有可定位 task，则 quickship 按无 task 模式收尾"
assert_contains "AGENTS.md" '`codev-taskdev` 负责从 `tasks/` 中选择目标 plan'
assert_contains "AGENTS.md" "默认 build / 最小编译校验"
assert_contains "AGENTS.md" '`codev-checkpoint` 是轻量 `commit/push` fallback，默认不同步根目录 `VERSION` / `CHANGELOG`'

for path in "${version_surface_files[@]}"; do
  assert_not_contains "$path" "$legacy_digit_label"
  assert_not_contains "$path" "$legacy_cn_label"
  assert_not_contains "$path" "$legacy_example"
  assert_not_matches "$path" "$legacy_numeric_regex"
done

assert_not_contains "skills/codev-quickship/SKILL.md" "$legacy_commit_example"
assert_not_contains "docs/skills/codev-quickship.md" "$legacy_commit_example"
assert_not_contains "CHANGELOG" "$legacy_commit_example"
assert_not_contains "skills/codev-checkpoint/SKILL.md" "最后一位加一"
assert_not_contains "docs/skills/codev-checkpoint.md" "最后一位加一"

echo "version rules checks passed"
