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

skills_dir_for_host() {
  local home_dir="$1"
  local host="$2"

  case "$host" in
    codex) printf '%s\n' "${home_dir}/.codex/skills" ;;
    *) fail "unknown host: ${host}" ;;
  esac
}

run_setup() {
  local home_dir="$1"
  shift
  HOME="$home_dir" "$SETUP_SCRIPT" "$@" >/dev/null
}

assert_host_installed() {
  local home_dir="$1"
  local host="$2"
  local skills_dir

  skills_dir="$(skills_dir_for_host "$home_dir" "$host")"
  assert_symlink_target "${skills_dir}/codev" "${REPO_ROOT}"
  for skill_name in "${MANAGED_SKILLS[@]}"; do
    assert_symlink_target "${skills_dir}/${skill_name}" "codev/skills/${skill_name}"
  done
  for skill_name in "${REMOVED_MANAGED_SKILLS[@]}"; do
    assert_missing "${skills_dir}/${skill_name}"
  done
  for skill_name in "${LEGACY_CODEV_SKILLS[@]}"; do
    assert_missing "${skills_dir}/${skill_name}"
  done
}

assert_host_missing() {
  local home_dir="$1"
  local host="$2"
  local skills_dir

  skills_dir="$(skills_dir_for_host "$home_dir" "$host")"
  assert_missing "${skills_dir}/codev"
  for skill_name in "${MANAGED_SKILLS[@]}"; do
    assert_missing "${skills_dir}/${skill_name}"
  done
}

exercise_default_codex_host() {
  local fresh_home="${TMP_ROOT}/default-fresh-home"
  local conflict_home="${TMP_ROOT}/default-conflict-home"
  local codex_skills

  mkdir -p "$fresh_home"
  run_setup "$fresh_home"
  assert_host_installed "$fresh_home" codex

  run_setup "$fresh_home"
  assert_host_installed "$fresh_home" codex

  codex_skills="$(skills_dir_for_host "$fresh_home" codex)"
  ln -snf "codev/skills/plantask" "${codex_skills}/plantask"
  for skill_name in "${REMOVED_MANAGED_SKILLS[@]}"; do
    ln -snf "codev/skills/${skill_name}" "${codex_skills}/${skill_name}"
  done
  for skill_name in "${LEGACY_CODEV_SKILLS[@]}"; do
    ln -snf "codev/skills/${skill_name}" "${codex_skills}/${skill_name}"
  done
  run_setup "$fresh_home"
  assert_host_installed "$fresh_home" codex

  mkdir -p "$(skills_dir_for_host "$conflict_home" codex)/codev-issue2task"
  if HOME="$conflict_home" "$SETUP_SCRIPT" >/dev/null 2>&1; then
    fail "setup should fail when a managed skill path is a real directory in default mode"
  fi

  assert_exists "$(skills_dir_for_host "$conflict_home" codex)/codev-issue2task"
  assert_missing "$(skills_dir_for_host "$conflict_home" codex)/codev"
}

exercise_single_host() {
  local host="$1"
  local fresh_home="${TMP_ROOT}/${host}-fresh-home"
  local conflict_home="${TMP_ROOT}/${host}-conflict-home"
  local setup_args=(--host "$host")

  mkdir -p "$fresh_home"
  run_setup "$fresh_home" "${setup_args[@]}"
  assert_host_installed "$fresh_home" "$host"

  run_setup "$fresh_home" "${setup_args[@]}"
  assert_host_installed "$fresh_home" "$host"

  for skill_name in "${REMOVED_MANAGED_SKILLS[@]}"; do
    ln -snf "codev/skills/${skill_name}" "$(skills_dir_for_host "$fresh_home" "$host")/${skill_name}"
  done
  for skill_name in "${LEGACY_CODEV_SKILLS[@]}"; do
    ln -snf "codev/skills/${skill_name}" "$(skills_dir_for_host "$fresh_home" "$host")/${skill_name}"
  done
  run_setup "$fresh_home" "${setup_args[@]}"
  assert_host_installed "$fresh_home" "$host"

  mkdir -p "$(skills_dir_for_host "$conflict_home" "$host")/codev-issue2task"
  if HOME="$conflict_home" "$SETUP_SCRIPT" "${setup_args[@]}" >/dev/null 2>&1; then
    fail "setup should fail when a managed skill path is a real directory for host ${host}"
  fi

  assert_exists "$(skills_dir_for_host "$conflict_home" "$host")/codev-issue2task"
  assert_missing "$(skills_dir_for_host "$conflict_home" "$host")/codev"
}

TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TMP_ROOT"' EXIT

exercise_single_host codex
exercise_default_codex_host

echo "setup smoke tests passed"
