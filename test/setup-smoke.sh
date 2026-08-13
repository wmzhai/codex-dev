#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
SETUP_SCRIPT="${REPO_ROOT}/setup"
MANAGED_SKILLS=(codev-memorize codev-issue2task codev-taskdev codev-quickship codev-simplify codev-checkpoint codev-syncpatch)
REMOVED_MANAGED_SKILLS=(codev-gstack2task codev-checktask codev-autodev codev-automerge)
LEGACY_CODEV_SKILLS=(plantask memorize issue2task gstack2task taskdev autodev automerge checktask simplify checkpoint ships)

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

codex_skills_dir() {
  local home_dir="$1"
  printf '%s\n' "${home_dir}/.codex/skills"
}

grok_skills_dir() {
  local home_dir="$1"
  printf '%s\n' "${home_dir}/.grok/skills"
}

run_setup() {
  local home_dir="$1"
  shift
  HOME="$home_dir" "$SETUP_SCRIPT" "$@" >/dev/null
}

assert_legacy_and_removed_missing() {
  local skills_dir="$1"
  local skill_name

  for skill_name in "${REMOVED_MANAGED_SKILLS[@]}"; do
    assert_missing "${skills_dir}/${skill_name}"
  done
  for skill_name in "${LEGACY_CODEV_SKILLS[@]}"; do
    assert_missing "${skills_dir}/${skill_name}"
  done
}

assert_codex_installed() {
  local home_dir="$1"
  local skills_dir
  local skill_name

  skills_dir="$(codex_skills_dir "$home_dir")"
  assert_symlink_target "${skills_dir}/codev" "${REPO_ROOT}"
  for skill_name in "${MANAGED_SKILLS[@]}"; do
    assert_symlink_target "${skills_dir}/${skill_name}" "codev/skills/${skill_name}"
  done
  assert_legacy_and_removed_missing "$skills_dir"
}

assert_grok_installed() {
  local home_dir="$1"
  local skills_dir
  local skill_name

  skills_dir="$(grok_skills_dir "$home_dir")"
  assert_missing "${skills_dir}/codev"
  for skill_name in "${MANAGED_SKILLS[@]}"; do
    assert_symlink_target "${skills_dir}/${skill_name}" "${REPO_ROOT}/skills/${skill_name}"
  done
  assert_legacy_and_removed_missing "$skills_dir"
}

assert_hosts_installed() {
  local home_dir="$1"

  assert_codex_installed "$home_dir"
  assert_grok_installed "$home_dir"
}

seed_legacy_links() {
  local skills_dir="$1"
  local skill_name

  mkdir -p "$skills_dir"
  ln -snf "codev/skills/plantask" "${skills_dir}/plantask"
  for skill_name in "${REMOVED_MANAGED_SKILLS[@]}"; do
    ln -snf "codev/skills/${skill_name}" "${skills_dir}/${skill_name}"
  done
  for skill_name in "${LEGACY_CODEV_SKILLS[@]}"; do
    ln -snf "codev/skills/${skill_name}" "${skills_dir}/${skill_name}"
  done
}

exercise_default_hosts() {
  local fresh_home="${TMP_ROOT}/default-fresh-home"
  local conflict_home="${TMP_ROOT}/default-conflict-home"
  local grok_conflict_home="${TMP_ROOT}/grok-conflict-home"

  mkdir -p "$fresh_home"
  run_setup "$fresh_home"
  assert_hosts_installed "$fresh_home"

  run_setup "$fresh_home"
  assert_hosts_installed "$fresh_home"

  seed_legacy_links "$(codex_skills_dir "$fresh_home")"
  seed_legacy_links "$(grok_skills_dir "$fresh_home")"
  ln -snf "$REPO_ROOT" "$(grok_skills_dir "$fresh_home")/codev"
  run_setup "$fresh_home"
  assert_hosts_installed "$fresh_home"

  mkdir -p "$(codex_skills_dir "$conflict_home")/codev-issue2task"
  if HOME="$conflict_home" "$SETUP_SCRIPT" >/dev/null 2>&1; then
    fail "setup should fail when a Codex managed skill path is a real directory"
  fi

  assert_exists "$(codex_skills_dir "$conflict_home")/codev-issue2task"
  assert_missing "$(codex_skills_dir "$conflict_home")/codev"
  assert_missing "$(grok_skills_dir "$conflict_home")/codev-issue2task"

  mkdir -p "$(grok_skills_dir "$grok_conflict_home")/codev-issue2task"
  if HOME="$grok_conflict_home" "$SETUP_SCRIPT" >/dev/null 2>&1; then
    fail "setup should fail when a Grok managed skill path is a real directory"
  fi

  assert_exists "$(grok_skills_dir "$grok_conflict_home")/codev-issue2task"
  assert_missing "$(grok_skills_dir "$grok_conflict_home")/codev"
}

TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TMP_ROOT"' EXIT

exercise_default_hosts

echo "setup smoke tests passed"
