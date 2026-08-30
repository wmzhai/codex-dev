# Claude Code 入口

本文件只服务 Claude Code。若当前宿主不是 Claude Code，忽略下面的宿主专用规则，只遵循 `memory/`。

## 必须先遵守

- 默认用简体中文与用户交流，除非用户明确要求英文或双语。
- 仓库事实与约束只写在 `memory/`，不要把公共正文再抄进本文件。
- 新会话先读 `memory/README.md` 和 `memory/core/invariants.md`。

## Claude Code 专用

- 面向用户提示下一步 skill 时用 `/name`，例如 `/codev-taskdev`。
- 本机 skills 目录：`~/.claude/skills/`。
- `setup` 仅在 PATH 中有 `claude` 时刷新该目录。

## 公共导航

- 流程：`docs/workflows.md`
- skill 手册：`docs/skills/README.md`
- 稳定约束：`memory/core/invariants.md`
