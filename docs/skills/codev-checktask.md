# `$codev-checktask`

Source: `codev`

## Purpose

按 task 文件中的验收标准逐项验证当前实现，更新 checklist，必要时归档任务，并同步 `memory/` 与任务直接相关的局部文档。

## Preconditions

- `tasks/` 中存在待办任务，或用户明确指定 task。
- 允许读取实现代码、测试入口和 task 文件。
- 只做验收与局部同步，不把它当成修功能入口。

## Inputs / Source Of Truth

- `tasks/Txx-*.md` 中的验收标准
- 当前实现代码与最小必要验证命令
- 本次任务相关的 `memory/` 与局部 `docs/`

## Produces / Writes

- 更新后的 task checklist
- 必要时归档到 `tasks/done/`
- 一次可选的 `codev-simplify` 式语义不变精简
- 与本任务直接相关的 `memory/` / 局部 `docs/` 更新

## Execution Flow

1. 选择目标 task，并读取 `Acceptance Criteria` 或对应验收段落。
2. 逐项验证，优先使用最小侵入的方法读取代码、跑针对性测试或静态检查。
3. 对明确通过的条目打勾，对失败或不确定项保持未通过。
4. 如果任务文档与已验证实现发生漂移，以已验证事实修正文档。
5. 所有标准都通过时，将任务移动到 `tasks/done/`；否则保留原位并报告缺口。
6. 在流程末尾最多做一次语义不变精简，并同步与任务直接相关的 `memory/` 与局部 `docs/`。

## Stops / Failure Modes

- 验收标准表述含糊，必须人工确认。
- 环境限制导致验证命令无法运行。
- 用户实际实现与 task 文档差异过大，无法安全判定验收口径。

## Next Recommended Steps

- 仍有缺口时，回到实现阶段修复
- 通过后进入 `$ship`、`$codev-quickship`，或在自动链路中等待 `$codev-automerge`
- 发现 repo 级文档漂移时，补跑 `$document-release`
