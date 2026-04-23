# Memory

`memory/` 是本仓库以 `AGENTS.md + memory/` 为核心的检索型记忆系统，回答“先看哪里、该改哪里、怎么验证”；它服务 Codex 工作流，入口为仓库级约束文档。

## 热路径
1. `AGENTS.md`
2. `docs/workflows.md`
3. `memory/core/symptom-routing.md`
4. 对应的 skill 手册：`docs/skills/*.md`

## 冷路径
- 仓库结构边界：`memory/core/system-map.md`
- 稳定约束：`memory/core/invariants.md`
- 默认动作与验证：`memory/core/workflows.md`
- 仓库职责边界：`memory/core/scope.md`

## 范围
- `core/`：仓库总图、症状路由、稳定约束、默认工作流
- `docs/workflows.md`：唯一工作流导航
- `docs/skills/`：每个 skill 的用户级详细手册
- `skills/`：各 skill 自身的 `SKILL.md` 仍然是运行规则来源
- 当仓库结构或安装链路变化时，优先先更新这里，再回头修 `README.md` 和测试脚本
