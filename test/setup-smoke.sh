#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
SETUP_SCRIPT="${REPO_ROOT}/setup"
MANAGED_SKILLS=(codev-memorize codev-issue2task codev-gstack2task codev-taskdev codev-autodev codev-quickship codev-automerge codev-checktask codev-simplify codev-checkpoint)
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

assert_file_contains() {
  local path="$1"
  local expected="$2"

  [ -f "$path" ] || fail "${path} should exist"
  grep -Fqx -- "$expected" "$path" || fail "${path} does not contain expected line: ${expected}"
}

make_fake_git() {
  local bin_dir="$1"
  mkdir -p "$bin_dir"

  cat > "${bin_dir}/git" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="${TEST_GIT_LOG:?}"

write_gstack_setup() {
  local target="$1"

  mkdir -p "$target/.git"
  cat > "$target/setup" <<'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail
[ "${1:-}" = "--host" ] || exit 21
[ "${2:-}" = "codex" ] || exit 22
echo "setup --host codex" >> "${HOME}/gstack-setup.log"
mkdir -p "${HOME}/.codex/skills"
touch "${HOME}/.codex/skills/.gstack-installed"
SCRIPT
  chmod +x "$target/setup"
}

echo "$*" >> "$LOG_FILE"

if [ "${1:-}" = "clone" ]; then
  repo="${2:-}"
  target="${3:-}"
  [ -n "$repo" ] && [ -n "$target" ] || exit 11
  mkdir -p "$(dirname "$target")"
  write_gstack_setup "$target"
  exit 0
fi

if [ "${1:-}" = "-C" ]; then
  repo_dir="${2:-}"
  cmd="${3:-}"
  [ -n "$repo_dir" ] && [ -n "$cmd" ] || exit 12
  shift 3
  if [ "$cmd" = "pull" ]; then
    [ -d "$repo_dir/.git" ] || exit 13
    write_gstack_setup "$repo_dir"
    echo "pull $*" >> "$LOG_FILE"
    exit 0
  fi
fi

exit 99
EOF

  chmod +x "${bin_dir}/git"
}

run_setup() {
  local home_dir="$1"
  local bin_dir="$2"
  TEST_GIT_LOG="${home_dir}/git.log" HOME="$home_dir" PATH="${bin_dir}:$PATH" "$SETUP_SCRIPT" >/dev/null
}

TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TMP_ROOT"' EXIT

fake_bin="${TMP_ROOT}/fake-bin"
make_fake_git "$fake_bin"

fresh_home="${TMP_ROOT}/fresh-home"
mkdir -p "$fresh_home"
run_setup "$fresh_home" "$fake_bin"

fresh_skills="${fresh_home}/.codex/skills"
assert_file_contains "${fresh_home}/git.log" "clone https://github.com/garrytan/gstack.git ${fresh_home}/gstack"
assert_file_contains "${fresh_home}/gstack-setup.log" "setup --host codex"
assert_exists "${fresh_skills}/.gstack-installed"
assert_symlink_target "${fresh_skills}/codev" "${REPO_ROOT}"
for skill_name in "${MANAGED_SKILLS[@]}"; do
  assert_symlink_target "${fresh_skills}/${skill_name}" "codev/skills/${skill_name}"
done
assert_missing "${fresh_skills}/plantask"
assert_missing "${fresh_skills}/ship"

run_setup "$fresh_home" "$fake_bin"
assert_file_contains "${fresh_home}/git.log" "-C ${fresh_home}/gstack pull --ff-only"
assert_file_contains "${fresh_home}/git.log" "pull --ff-only"
assert_symlink_target "${fresh_skills}/codev" "${REPO_ROOT}"
for skill_name in "${MANAGED_SKILLS[@]}"; do
  assert_symlink_target "${fresh_skills}/${skill_name}" "codev/skills/${skill_name}"
done
assert_missing "${fresh_skills}/plantask"

ln -snf "codev/skills/plantask" "${fresh_skills}/plantask"
for skill_name in "${LEGACY_CODEV_SKILLS[@]}"; do
  ln -snf "codev/skills/${skill_name}" "${fresh_skills}/${skill_name}"
done
run_setup "$fresh_home" "$fake_bin"
for skill_name in "${LEGACY_CODEV_SKILLS[@]}"; do
  assert_missing "${fresh_skills}/${skill_name}"
done

conflict_home="${TMP_ROOT}/conflict-home"
conflict_skills="${conflict_home}/.codex/skills"
mkdir -p "${conflict_skills}/codev-issue2task"

if TEST_GIT_LOG="${conflict_home}/git.log" HOME="$conflict_home" PATH="${fake_bin}:$PATH" "$SETUP_SCRIPT" >/dev/null 2>&1; then
  fail "setup should fail when a managed skill path is a real directory"
fi

assert_exists "${conflict_skills}/codev-issue2task"
assert_missing "${conflict_skills}/codev"
assert_missing "${conflict_skills}/codev-checkpoint"
for skill_name in "${LEGACY_CODEV_SKILLS[@]}"; do
  assert_missing "${conflict_skills}/${skill_name}"
done

non_repo_home="${TMP_ROOT}/non-repo-home"
mkdir -p "${non_repo_home}/gstack"
if TEST_GIT_LOG="${non_repo_home}/git.log" HOME="$non_repo_home" PATH="${fake_bin}:$PATH" "$SETUP_SCRIPT" >/dev/null 2>&1; then
  fail "setup should fail when ~/gstack is not a git repository"
fi

assert_exists "${non_repo_home}/gstack"
assert_missing "${non_repo_home}/.codex/skills/codev"

echo "setup smoke tests passed"
