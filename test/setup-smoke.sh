#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
SETUP_SCRIPT="${REPO_ROOT}/setup"
MANAGED_SKILLS=(codev-memorize codev-issue2task codev-taskdev codev-quickship codev-simplify codev-checkpoint codev-syncpatch)
REMOVED_MANAGED_SKILLS=(codev-gstack2task codev-checktask codev-autodev codev-automerge)
LEGACY_CODEV_SKILLS=(plantask memorize issue2task gstack2task taskdev autodev automerge checktask simplify checkpoint ships)
SAFE_PATH="/usr/bin:/bin:/usr/sbin:/sbin"

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

claude_skills_dir() {
  local home_dir="$1"
  printf '%s\n' "${home_dir}/.claude/skills"
}

make_clients() {
  local bin_dir="$1"
  shift
  local name

  mkdir -p "$bin_dir"
  for name in "$@"; do
    printf '#!/bin/sh\nexit 0\n' > "${bin_dir}/${name}"
    chmod +x "${bin_dir}/${name}"
  done
}

run_setup() {
  local home_dir="$1"
  local bin_dir="$2"

  HOME="$home_dir" PATH="${bin_dir}:${SAFE_PATH}" "$SETUP_SCRIPT" >/dev/null
}

run_setup_capture() {
  local home_dir="$1"
  local bin_dir="$2"

  HOME="$home_dir" PATH="${bin_dir}:${SAFE_PATH}" "$SETUP_SCRIPT" 2>&1
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

assert_direct_host_installed() {
  local skills_dir="$1"
  local skill_name

  assert_missing "${skills_dir}/codev"
  for skill_name in "${MANAGED_SKILLS[@]}"; do
    assert_symlink_target "${skills_dir}/${skill_name}" "${REPO_ROOT}/skills/${skill_name}"
  done
  assert_legacy_and_removed_missing "$skills_dir"
}

assert_grok_installed() {
  local home_dir="$1"

  assert_direct_host_installed "$(grok_skills_dir "$home_dir")"
}

assert_claude_installed() {
  local home_dir="$1"

  assert_direct_host_installed "$(claude_skills_dir "$home_dir")"
}

assert_codex_skipped() {
  local home_dir="$1"

  assert_missing "$(codex_skills_dir "$home_dir")"
  assert_missing "${home_dir}/.codex"
}

assert_grok_skipped() {
  local home_dir="$1"

  assert_missing "$(grok_skills_dir "$home_dir")"
  assert_missing "${home_dir}/.grok"
}

assert_claude_skipped() {
  local home_dir="$1"

  assert_missing "$(claude_skills_dir "$home_dir")"
  assert_missing "${home_dir}/.claude"
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

exercise_detection_and_hosts() {
  local all_bin="${TMP_ROOT}/bin-all"
  local none_bin="${TMP_ROOT}/bin-none"
  local grok_bin="${TMP_ROOT}/bin-grok"
  local mixed_bin="${TMP_ROOT}/bin-mixed"
  local all_home="${TMP_ROOT}/all-home"
  local none_home="${TMP_ROOT}/none-home"
  local grok_home="${TMP_ROOT}/grok-home"
  local mixed_home="${TMP_ROOT}/mixed-home"
  local idem_home="${TMP_ROOT}/idem-home"
  local conflict_codex_home="${TMP_ROOT}/conflict-codex-home"
  local conflict_grok_home="${TMP_ROOT}/conflict-grok-home"
  local conflict_claude_home="${TMP_ROOT}/conflict-claude-home"
  local leftover_home="${TMP_ROOT}/leftover-claude-home"
  local output

  make_clients "$all_bin" codex grok claude
  make_clients "$none_bin"
  make_clients "$grok_bin" grok
  make_clients "$mixed_bin" grok claude

  mkdir -p "$all_home" "$none_home" "$grok_home" "$mixed_home" "$idem_home"
  mkdir -p "$conflict_codex_home" "$conflict_grok_home" "$conflict_claude_home" "$leftover_home"

  output="$(run_setup_capture "$none_home" "$none_bin")" && fail "setup should fail when no supported client is in PATH"
  printf '%s\n' "$output" | grep -Fq "need one of: codex, grok, claude" \
    || fail "missing-client failure should mention supported binaries"
  assert_codex_skipped "$none_home"
  assert_grok_skipped "$none_home"
  assert_claude_skipped "$none_home"

  run_setup "$all_home" "$all_bin"
  assert_codex_installed "$all_home"
  assert_grok_installed "$all_home"
  assert_claude_installed "$all_home"

  run_setup "$idem_home" "$all_bin"
  run_setup "$idem_home" "$all_bin"
  assert_codex_installed "$idem_home"
  assert_grok_installed "$idem_home"
  assert_claude_installed "$idem_home"

  seed_legacy_links "$(codex_skills_dir "$idem_home")"
  seed_legacy_links "$(grok_skills_dir "$idem_home")"
  seed_legacy_links "$(claude_skills_dir "$idem_home")"
  ln -snf "$REPO_ROOT" "$(grok_skills_dir "$idem_home")/codev"
  ln -snf "$REPO_ROOT" "$(claude_skills_dir "$idem_home")/codev"
  run_setup "$idem_home" "$all_bin"
  assert_codex_installed "$idem_home"
  assert_grok_installed "$idem_home"
  assert_claude_installed "$idem_home"

  run_setup "$grok_home" "$grok_bin"
  assert_codex_skipped "$grok_home"
  assert_grok_installed "$grok_home"
  assert_claude_skipped "$grok_home"

  run_setup "$mixed_home" "$mixed_bin"
  assert_codex_skipped "$mixed_home"
  assert_grok_installed "$mixed_home"
  assert_claude_installed "$mixed_home"

  mkdir -p "$(codex_skills_dir "$conflict_codex_home")/codev-issue2task"
  HOME="$conflict_codex_home" PATH="${all_bin}:${SAFE_PATH}" "$SETUP_SCRIPT" >/dev/null 2>&1 \
    && fail "setup should fail when a Codex managed skill path is a real directory"
  assert_exists "$(codex_skills_dir "$conflict_codex_home")/codev-issue2task"
  assert_missing "$(codex_skills_dir "$conflict_codex_home")/codev"
  assert_missing "$(grok_skills_dir "$conflict_codex_home")/codev-issue2task"
  assert_missing "$(claude_skills_dir "$conflict_codex_home")/codev-issue2task"

  mkdir -p "$(grok_skills_dir "$conflict_grok_home")/codev-issue2task"
  HOME="$conflict_grok_home" PATH="${grok_bin}:${SAFE_PATH}" "$SETUP_SCRIPT" >/dev/null 2>&1 \
    && fail "setup should fail when a Grok managed skill path is a real directory"
  assert_exists "$(grok_skills_dir "$conflict_grok_home")/codev-issue2task"
  assert_codex_skipped "$conflict_grok_home"
  assert_claude_skipped "$conflict_grok_home"

  mkdir -p "$(claude_skills_dir "$conflict_claude_home")/codev-issue2task"
  HOME="$conflict_claude_home" PATH="${all_bin}:${SAFE_PATH}" "$SETUP_SCRIPT" >/dev/null 2>&1 \
    && fail "setup should fail when a Claude managed skill path is a real directory"
  assert_codex_installed "$conflict_claude_home"
  assert_grok_installed "$conflict_claude_home"
  assert_exists "$(claude_skills_dir "$conflict_claude_home")/codev-issue2task"
  assert_missing "$(claude_skills_dir "$conflict_claude_home")/codev-memorize"

  mkdir -p "$(claude_skills_dir "$leftover_home")"
  ln -snf "$REPO_ROOT" "$(claude_skills_dir "$leftover_home")/codev"
  run_setup "$leftover_home" "$all_bin"
  assert_claude_installed "$leftover_home"
}

TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TMP_ROOT"' EXIT

exercise_detection_and_hosts

echo "setup smoke tests passed"
