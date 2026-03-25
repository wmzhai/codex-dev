---
name: codev-gstack2task
description: 从 `~/.gstack/projects/` 下与当前仓库相关的 gstack 工件读取设计、交接和测试计划，结合现有代码生成 `tasks/` 下可直接执行的任务计划文件；默认只生成一个 task，只有在 Codex 判断必须拆成多个 task 时才先向用户确认拆分清单。适用于上游已经跑过 gstack `$office-hours`、`$plan-*`，现在需要把这些工件和 repo 实现现状一起压成 repo 内执行单元，并在审核后交给 `$codev-taskdev` 或 `$codev-autodev` 的场景。
---

# Gstack2Task

把 gstack 在 `~/.gstack/projects/` 里产出的上游工件，结合当前代码收敛成 repo 内可执行的任务计划文件。

这个 skill 聚焦“把上游规划压成 task plan”。它不查询 GitHub issue，也不重复做一轮高层产品讨论，但必须把上游约束映射到 repo 里的真实实现入口。

## 第一规则：先用中文交流

- skill 一触发，第一句就用中文和用户交流。
- 整个执行过程中的工件判断、阻塞说明、计划摘要和结果汇报默认都用中文。
- 只有用户明确要求英文或双语时，才切换语言。

## Inputs

从用户请求推断目标工件：

- 如果用户直接给了 `~/.gstack/projects/...` 下的文件路径，优先使用这个文件，并补读同项目、同分支下相关的最新工件。
- 如果用户给了 gstack project slug，如 `wyckoff`，使用 `~/.gstack/projects/<slug>/`。
- 如果用户没有给参数，先根据当前 git 仓库推断 project slug，并优先找当前分支对应的最新工件。

## Supported Artifacts

优先级从高到低：

1. `*-implementation-plan-*.md` 或其它 implementation handoff
2. `*-test-plan-*.md`
3. `*-design-*.md`
4. `*-ceo-handoff-*.md`、`ceo-plans/*.md`

当多个工件同时存在时，应把高优先级工件视为执行边界来源，低优先级工件视为补充上下文。

## Workflow

1. 确认当前目录是 git 仓库，并确认 `~/.gstack/projects/` 存在。缺少任一前提时明确报告阻塞并停止。
2. 定位 gstack project 目录：
   - 直接文件路径模式：从该文件反推 project 目录。
   - slug 模式：使用 `~/.gstack/projects/<slug>/`。
   - 无参数模式：优先根据当前仓库 remote slug 或仓库目录名匹配同名 project 目录；如果结果不唯一，明确指出候选项并停止。
3. 读取当前分支对应的最新工件；如果当前分支没有工件，再回退到该 project 目录下最新的同类型工件。
4. 综合这些工件后，大量阅读相关代码，确认：
   - 当前行为和数据流是什么。
   - 相关模块、接口、页面、脚本和测试入口在哪里。
   - 上游 handoff 里没写但代码现状真实存在的约束是什么。
   - 哪些实现路径最贴近当前 repo 模式。
5. 提取真正应该进入 repo 的执行信息：
   - 功能边界与 out-of-scope
   - 非协商约束
   - 关键用户场景与交互状态
   - 测试计划里的关键路径与边界条件
   - 明确的阶段拆分或可独立落地的子任务
6. 基于工件和代码现状直接写出可执行 plan：
   - 推荐默认实现路径，并简短说明放弃其它路径的原因。
   - 标出计划修改或新增的关键文件、模块、接口和脚本。
   - 写清实施顺序、关键假设、风险点和最小验证链。
   - implementation handoff 明确的步骤可以继承，但必须落到当前 repo 的实际代码入口。
7. 默认保守拆分：
   - 默认生成一个任务。
   - 即使 implementation handoff 或 test plan 里已经出现阶段划分，也应先尝试收敛成一个可执行总任务，不要自动跟随上游工件拆成多个 task。
   - 只有当 Codex 依据代码边界、实施顺序、风险隔离或依赖关系判断“单个 task 已无法安全承载实现与验收”时，才可以建议拆成多个任务。
   - 一旦判断需要多任务，必须先向用户发起一次明确确认，列出建议生成的每个 task 的标题、范围、关键文件/模块、依赖关系，以及为什么不能继续合并成一个 task。
   - 只有在用户明确确认这份拆分清单后，才能真正创建多个 task 文件和对应分支；没有确认前，不要自动拆解生成多个 task。
   - 如果拆成多个任务，也按连续的新整数任务号分别创建，不再使用字母后缀。
8. 创建或复用仓库根目录的 `tasks/`。
9. 分配编号规则与 `codev-issue2task` 保持一致：
   - 扫描 `tasks/` 和 `tasks/done/` 中已有任务文件名的基础整数部分，取最大值顺延；如果还没有任务，从 `T01` 开始。
   - 多任务场景按连续的新整数任务号分别创建，例如 `T12`、`T13`、`T14`。
10. 先为本次将要创建的每个 task 计算目标文件名和对应分支名。
11. 为每个任务分别执行以下动作：
   - 先新建一个分支，并切到这个新分支。
   - 默认分支名使用该 task 文件去掉 `.md` 后的文件名。
   - 如果同名分支已存在，为保证“每个 task 一个独立 branch”，应改用带短后缀的新分支名，并在结果摘要里说明。
   - 在当前分支写入该 task 文件。
12. 为每个任务写入 `tasks/T{nn}-{slug}.md`，模板如下：

```markdown
# T{nn}: {任务标题}

Source: gstack project artifacts

## Source Artifacts

- `~/.gstack/projects/.../foo-implementation-plan-....md`
- `~/.gstack/projects/.../foo-test-plan-....md`

## Source Context

- {从 design / handoff / test plan 提取的关键背景}

## Task Description

{整理后的完整需求，反映 gstack 工件已经确认的范围、约束与交付目标}

## Acceptance Criteria

- [ ] 标准 1
- [ ] 标准 2

## Related Code

- `path/to/file.ts` - 当前行为、关联模块或约束说明

## Implementation Plan

### Proposed Approach

{推荐实现路径，说明如何把 gstack 工件里的边界映射到当前 repo 的真实代码入口}

### File Changes

- `path/to/file.ts` - 计划修改原因
- `path/to/new-file.ts` - 计划新增原因

### Execution Order

1. 第一步
2. 第二步

### Assumptions / Open Questions

- 假设 1
- 如无则写 `None`

## Validation Plan

- [ ] 验证 1
- [ ] 验证 2

## Dependencies

{任务编号列表或 "None"}

## Notes

{可选：保留对实现有影响的非协商约束、测试重点或阶段说明}
```

13. 输出简短摘要，包含使用了哪些 gstack 工件、创建了多少任务、每个任务对应的新分支名、任务依赖关系，以及“用户接下来应审核 task plan，再进入 `$codev-taskdev` 或 `$codev-autodev`”的提示。

## Rules

- 不要查询 GitHub issue；那是 `codev-issue2task` 的职责。
- 不要把 gstack 的高层产品叙事整段搬进任务文件；只保留会影响实现和验收的事实。
- implementation handoff 与 test plan 的约束优先于 design doc 的宽泛表述；冲突时，在任务文件里按已读取工件显式收敛。
- 只写已经在工件里明确确认的范围和限制；没有依据时不要脑补产品方向。
- 不要只把 handoff 原文换个说法抄进 task；必须结合真实代码把 plan 落到具体入口和实施顺序。
- 默认只产出一个 task，不要因为上游工件写了 phase、milestone 或 checklist 就自动拆成多个。
- 如果判断必须拆成多个 task，先用中文向用户给出明确的拆分清单，再等待用户确认；未经确认不得创建多个 task 文件。
- 这次确认必须包含每个 task 的内容清单，而不是只问“要不要拆分”。
- 每个 task 文件都必须写在它自己的新分支上；不要让多个 task 共用同一条实现分支。
- 默认直接产出任务文件，不把“等待用户二次确认”当成标准中间步骤；只有 project slug 无法确定、工件冲突严重且无法自行收敛，或判断必须拆成多个 task 时才提问。
- task 文件里的 `Implementation Plan` 和 `Validation Plan` 必须足够具体，使用户审核后可以直接开始实现，而不是再补一轮规划。
- 不要提交代码。文件创建就是这个 skill 的最终副作用。
