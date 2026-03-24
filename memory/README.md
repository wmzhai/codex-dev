# Memory

`memory/` 是本仓库面向 Codex 的检索型记忆系统，回答“先看哪里、该改哪里、怎么验证”。

## 热路径
1. `AGENTS.md`
2. `memory/core/symptom-routing.md`
3. `memory/core/gstack-interoperability.md`
4. 对应的 skill 目录：`skills/memorize/`、`skills/issue2task/`、`skills/gstack2task/`、`skills/taskdev/`、`skills/checktask/`、`skills/simplify/`、`skills/checkpoint/`

## 冷路径
- 仓库结构边界：`memory/core/system-map.md`
- 稳定约束：`memory/core/invariants.md`
- 默认动作与验证：`memory/core/workflows.md`
- 与 gstack 的协同边界：`memory/core/gstack-interoperability.md`

## 范围
- `core/`：仓库总图、症状路由、稳定约束、默认工作流
- `skills/`：各 skill 自身的 `SKILL.md` 已经是主要知识来源
- 当仓库结构或安装链路变化时，优先先更新这里，再回头修 `README.md` 和测试脚本
