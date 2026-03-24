#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
SETUP_SCRIPT="${REPO_ROOT}/setup"
MANAGED_SKILLS=(memorize issue2task gstack2task taskdev autodev automerge checktask simplify checkpoint)

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_symlink_target() {
  local path="$1"
  local expected="$2"
  local actual

  [ -L "$path" ] || fail "${path} is not a symlink"
  actual="$(readlink "$path")"
  [ "$actual" = "$expected" ] || fail "${path} points to ${actual}, expected ${expected}"
}

assert_missing() {
  local path="$1"
  [ ! -e "$path" ] && [ ! -L "$path" ] || fail "${path} should be missing"
}

assert_exists() {
  local path="$1"
  [ -e "$path" ] || [ -L "$path" ] || fail "${path} should exist"
}

run_setup() {
  local home_dir="$1"
  HOME="$home_dir" "$SETUP_SCRIPT" >/dev/null
}

TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TMP_ROOT"' EXIT

fresh_home="${TMP_ROOT}/fresh-home"
mkdir -p "$fresh_home"
run_setup "$fresh_home"

fresh_skills="${fresh_home}/.codex/skills"
assert_symlink_target "${fresh_skills}/codev" "${REPO_ROOT}"
for skill_name in "${MANAGED_SKILLS[@]}"; do
  assert_symlink_target "${fresh_skills}/${skill_name}" "codev/skills/${skill_name}"
done
assert_missing "${fresh_skills}/plantask"
assert_missing "${fresh_skills}/ship"

run_setup "$fresh_home"
assert_symlink_target "${fresh_skills}/codev" "${REPO_ROOT}"
for skill_name in "${MANAGED_SKILLS[@]}"; do
  assert_symlink_target "${fresh_skills}/${skill_name}" "codev/skills/${skill_name}"
done
assert_missing "${fresh_skills}/plantask"

ln -snf "codev/skills/plantask" "${fresh_skills}/plantask"
run_setup "$fresh_home"
assert_missing "${fresh_skills}/plantask"

conflict_home="${TMP_ROOT}/conflict-home"
conflict_skills="${conflict_home}/.codex/skills"
mkdir -p "${conflict_skills}/issue2task"

if HOME="$conflict_home" "$SETUP_SCRIPT" >/dev/null 2>&1; then
  fail "setup should fail when a managed skill path is a real directory"
fi

assert_exists "${conflict_skills}/issue2task"
assert_missing "${conflict_skills}/codev"
assert_missing "${conflict_skills}/checkpoint"
assert_missing "${conflict_skills}/plantask"
assert_missing "${conflict_skills}/ships"

echo "setup smoke tests passed"
