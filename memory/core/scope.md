# Codev Scope

只在仓库边界不清时读本文。

## 职责范围
- codev：负责 `tasks/`、任务内实现计划、`codev-taskdev`、`codev-quickship`、`codev-memorize`、`codev-simplify`、`codev-checkpoint` 与 `codev-syncpatch`。
- 本仓库文档只描述 codev 自身受管流程，不维护外部工具或外部 skill 的说明。

## 任务入口
- `codev-issue2task`：输入是 GitHub issue 或用户直接需求。
- `tasks/` 是 repo 内执行单元，任务生成统一走 `codev-issue2task`。

## Source Of Truth
- repo 内执行单元：`tasks/`
- 机器记忆：`AGENTS.md` + `memory/`
- 对外流程导航：`docs/workflows.md`
- 对外 skill 手册：`docs/skills/README.md`
- repo 级人类文档：`README.md`、`CHANGELOG`

## 不冲突规则
- `codev-memorize` 以 `AGENTS.md + memory/` 统一收敛 repo 事实，不再维护额外入口文件。
- `$codev-taskdev` 只负责按已审核 plan 实施代码、同步任务文档，并在实现收尾做一次语义不变精简和一次默认 build / 最小编译校验。
- 只有明确需要轻量 `commit/push` 时，才用 `$codev-checkpoint`。
- `$codev-quickship` 负责人工验证后的收尾：归档 task、同步任务相关 `docs/` / `memory/` / 必要时 `AGENTS.md`；有 task 时沿用 `codev-taskdev` 已完成的默认 build，无 task 时才补跑，并同步根目录 `VERSION`、`CHANGELOG`，再提交、合并并推送主干。
- `$codev-syncpatch` 只负责同步开源 upstream 并保留本地运行补丁；默认不提交、不 push、不默认创建分支，且必须先判断补丁能否按原意安全重放。

## 推荐组合方式
1. 输入来自 GitHub issue 或直接需求时，用 `codev-issue2task`
2. 用户先审核 task 文件中的实现计划
3. 用 `$codev-taskdev` 落成代码，并持续维护任务文档
4. 人工验证功能
5. 人工确认通过后用 `codev-quickship` 做收尾
