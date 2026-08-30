# Memory

`memory/` 是本仓库的公共记忆正文，回答“先看哪里、该改哪里、怎么验证”。Codex、Grok 和 Claude Code 都读这里；各宿主入口文件只负责专用前缀和跳转。

## 热路径
1. 当前宿主入口：`AGENTS.md`（Codex）、`CLAUDE.md`（Claude Code）或 `.grok/rules/memory.md`（Grok）
2. `memory/core/invariants.md`
3. `docs/workflows.md`
4. `memory/core/symptom-routing.md`
5. 对应的 skill 手册：`docs/skills/*.md`

## 冷路径
- 仓库结构边界：`memory/core/system-map.md`
- 默认动作与验证：`memory/core/workflows.md`
- 仓库职责边界：`memory/core/scope.md`

## 范围
- `core/`：仓库总图、症状路由、稳定约束、默认工作流
- `docs/workflows.md`：唯一工作流导航
- `docs/skills/`：每个 skill 的用户级详细手册
- `skills/`：各 skill 自身的 `SKILL.md` 仍然是运行规则来源
- 当仓库结构或安装链路变化时，优先先更新这里，再回头修入口文件、`README.md` 和测试脚本
