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

for path in \
  "skills/codev-issue2task/SKILL.md" \
  "skills/codev-taskdev/SKILL.md"
do
  assert_contains "$path" "Grok / Grok Build TUI"
  assert_contains "$path" "/<skill-name>"
  assert_contains "$path" '$<skill-name>'
done

assert_not_contains "skills/codev-issue2task/SKILL.md" '再进入 `$codev-taskdev`'
assert_not_contains "skills/codev-taskdev/SKILL.md" '确认通过后再用 `$codev-quickship`'

assert_contains "docs/skills/codev-issue2task.md" "/codev-taskdev"
assert_contains "docs/skills/codev-taskdev.md" "/codev-quickship"
assert_contains "README.md" "Grok 把 \`$\` 换成 \`/\`"
assert_contains "docs/workflows.md" "Grok 把 \`$\` 换成 \`/\`"

echo "skill invocation prefix checks passed"
