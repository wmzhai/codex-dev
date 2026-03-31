# Claude Guide

默认先读：

1. `README.md`
2. `docs/workflows/README.md`
3. `docs/skills/README.md`
4. `AGENTS.md`

## 安装

- 默认 `./setup` 会同时安装到 `~/.claude/skills/` 和 `~/.codex/skills/`
- 仅安装 Claude：`./setup --host claude`
- 仅安装 Codex：`./setup --host codex`
- 当前仓库暂不支持项目内 `.claude/skills/` 或 `.agents/skills/` vendored 安装

## 兼容约束

- 默认用简体中文与用户交流，除非用户明确要求英文或双语。
- `AGENTS.md` 和 `memory/` 仍是 repo 事实与检索入口的主来源；本文件只保留 Claude 入口和兼容说明。
- 新增或修改 skill 时，优先同步 `SKILL.md`、`agents/openai.yaml`、`docs/skills/<skill>.md`、`setup`、`test/setup-smoke.sh` 和 `README.md`。
- 如果仓库同时使用 gstack，保留仍然服务宿主代理或 gstack 的兼容说明，不要把这些内容并回 `AGENTS.md`。
