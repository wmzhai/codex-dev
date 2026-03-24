# 人工深度参与流程

这份文档讲的是另一条路：不是把流程交给 `autodev` / `automerge` 自动收口，而是让人类在每个关键步骤都深度参与、显式判断、显式推进。

它适合高控制度团队、复杂项目、多人协作场景，也适合那些不满足分支部署前提、无法安全采用半自动路径的仓库。

它不展开每个 skill 的完整内部工作流。需要查 skill 级细节、产物路径、clean tree 要求和 stop 条件时，跳到 [Skill 详细手册](skill-reference.md)。

## 什么时候更适合这条路

- 你希望每一步都由人类明确判断，而不是只在少数节点介入。
- 仓库没有 preview / staging / branch deploy，无法用 `autodev` 停在分支验证结果。
- 任务跨度大、变数多，人在中途经常要改 scope、改方案、改优先级。
- 你需要把规划、设计、工程、验证、发布分成明确的阶段门禁。

## 高层链路

```text
$memorize
-> $office-hours
-> $plan-ceo-review
-> $design-consultation
-> $plan-design-review
-> $plan-eng-review
-> $gstack2task 或 $issue2task
-> 审核 task plan
-> 实现
-> $simplify
-> 普通 commit 或 $checkpoint
-> $design-review
-> $review
-> $qa
-> $checktask
-> $ship
-> （可选）$document-release
-> $land-and-deploy
-> $retro
```

不是每次都必须跑完整条链，但如果你选择人工路径，默认思维方式应该是：每个阶段都由人类决定是否通过，而不是默认自动往前冲。

## 详细流程图

```text
┌──────────────────────────── main/master ────────────────────────────┐
│                                                                     │
│  $memorize                                                          │
│    └─► AGENTS.md + memory/ (repo 内)                                │
│                                                                     │
│  $office-hours                                                      │
│    └─► ~/.gstack/projects/{slug}/*-design-*.md                      │
│         设计文档                                                    │
│                                                                     │
│  $plan-ceo-review   ←── 读 design doc                               │
│    └─► ~/.gstack/projects/{slug}/ceo-plans/*.md                     │
│         CEO 计划                                                    │
│                                                                     │
│  $design-consultation ←── 有 UI 且无 DESIGN.md 时                   │
│    └─► DESIGN.md (repo 根目录)                                      │
│         设计系统：字体 / 色彩 / 间距 / 动效                          │
│                                                                     │
│  $plan-design-review ←── 读 DESIGN.md                               │
│    └─► 设计完整度评分 0-10                                          │
│         修补后的 plan 文件                                           │
│                                                                     │
│  $plan-eng-review   ←── 读 design doc + DESIGN.md                   │
│    └─► 架构图 + ~/.gstack/projects/{slug}/*-test-plan-*.md          │
│                                                                     │
└─────────────────────────────┬───────────────────────────────────────┘
                              │ 此处切入 task 分支
                              ▼
┌──────── task 分支 (每个 task 一条独立分支) ──────────────────────────┐
│                                                                     │
│  $gstack2task 或 $issue2task                                        │
│    └─► tasks/T{nn}-{slug}.md + 新建并切到 task 分支                 │
│         任务文件内同时包含需求、Implementation Plan、Validation Plan │
│                                                                     │
│  人工审核 task plan                                                 │
│    └─► 确认任务边界、实现路径、验证链                               │
│         不接受就回到 task 文件继续收敛                               │
│                                                                     │
│  （中到大改动时）$plan-eng-review 或 $autoplan                       │
│    └─► 对当前 task 分支补齐 review；scope 漂移后可重跑               │
│                                                                     │
│  实现代码                                                            │
│    │                                                                 │
│    ▼                                                                 │
│  $simplify ─── 语义不变精简，收窄 patch                              │
│    │                                                                 │
│    ▼                                                                 │
│  普通 commit 或 $checkpoint ─── 提交 clean tree                     │
│    │                                                                 │
│    ▼                                                                 │
│  （有 UI 时）$design-review ─── 视觉 QA + 原子 fix commits          │
│    │                                                                 │
│    ▼                                                                 │
│  $review ─── 结构性 code review，可能 auto-fix                      │
│    │ (若改了代码 → 验证 → 必要时补 $simplify → 补 commit)           │
│    ▼                                                                 │
│  $qa ─── 打开真实浏览器测试用户流程                                  │
│    │                                                                 │
│    ▼                                                                 │
│  $checktask ─── 逐项验收 → 归档到 tasks/done/ → 同步 memory/       │
│    │                                                                 │
│    ▼                                                                 │
│  $ship ─── 测试 + 覆盖率 + review + 版本号 + CHANGELOG + PR         │
│                                                                     │
└─────────────────────────────┬───────────────────────────────────────┘
                              │
                              ▼
┌───────── 合并与部署 ─────────────────────────────────────────────────┐
│                                                                     │
│  $land-and-deploy                                                   │
│    ├─► 预合并就绪门禁 (CI 绿 + review approved)                     │
│    ├─► gh pr merge (squash / rebase / merge)                        │
│    ├─► 等 CI + 部署完成                                              │
│    └─► $canary 自动验证生产健康度                                    │
│                                                                     │
│  $document-release (可选，通常接在 $ship 后)                        │
│    └─► 同步 README / ARCHITECTURE / CONTRIBUTING / CHANGELOG        │
│                                                                     │
│  $retro (可选，每周)                                                │
│    └─► 工程复盘报告 (commit 分析 + 代码质量 + 工作模式)             │
│                                                                     │
└──────────────────────────────────────────────────────────────────────┘
```

## 阶段总览

| 阶段 | 人类要做的事 | 常用 skill | 阶段结束后应该看到什么 |
|------|--------------|-----------|------------------------|
| 仓库记忆 | 确认 repo 结构和约束是否最新 | `$memorize` | `AGENTS.md` 和 `memory/` 与真实代码一致 |
| 上游规划 | 决定问题、方向、范围、设计与工程边界 | gstack 规划类 skill | 上游设计文档、review 结果、测试计划稳定 |
| 任务生成 | 决定 task 如何拆分，并让 task 自带可执行 plan | `$gstack2task` / `$issue2task` | `tasks/` 中有可执行任务、实现计划和对应分支 |
| plan 审核 | 决定是否接受当前 task 的实现路径 | 人工审核 task 文件 | 可执行方案明确 |
| 实现与收口 | 亲自控制代码演进、精简和提交节奏 | 实现 + `$simplify` + commit / `$checkpoint` | 当前 task 分支形成稳定 patch |
| 设计 / 代码 / 浏览器验证 | 逐步判断是否需要继续改 | `$design-review`、`$review`、`$qa` | 验证结果明确，必要修复已完成 |
| 验收 | 人工确认验收标准是否真的通过 | `$checktask` | task 文档更新完毕并归档或保留缺口 |
| 发布 | 人工控制版本号、PR、合并、部署和文档同步 | `$ship`、`$document-release`、`$land-and-deploy` | 主干、部署、文档都收口完毕 |

## 阶段 1：先把仓库记忆整理好

`$memorize` 是人工路径的起点之一，因为它决定后面所有 skill 看见的是不是最新 repo 事实。

人在这一步的职责是确认：

- `AGENTS.md` 是否还反映当前仓库约束
- `memory/` 是否还能正确路由新 session
- 有没有过期的入口、目录或流程文档

如果 repo 结构刚变过，先做这一步，再开始后面的规划或实现。

## 阶段 2：上游规划完全由人带着走

这条路径里，上游规划不交给一个总编排器，而是逐步推进。

### 2.1 `$office-hours`

人类在这里的职责不是回答实现细节，而是把问题本身讲清楚：

- 到底要解决什么
- 为什么现在做
- 目标用户是谁
- 还有哪些备选方案

### 2.2 `$plan-ceo-review`

人在这里主要判断：

- scope 要不要更大
- 哪些东西应该砍掉
- 这个方向是不是值得做

### 2.3 `$design-consultation` / `$plan-design-review`

只要任务有明显 UI 或设计系统影响，人就应该在这里做显式设计判断，而不是把“到时候再 polish”留给实现后。

### 2.4 `$plan-eng-review`

这是人工路径里最关键的工程门禁之一。人在这里要确认：

- 架构是不是过度了
- 测试计划是不是完整
- 边界条件、失败模式、部署风险是不是已经写清楚

如果上游规划阶段 scope 还在漂移，就不要急着进 task。

## 阶段 3：生成 task，并让 task 成为 repo 内执行单元

这里的关键判断不是“要不要建 task”，而是“task 怎么拆最合理”。

- 上游已经在 `~/.gstack/projects/` 里，则用 `$gstack2task`
- 需求在 GitHub issue 或用户描述里，则用 `$issue2task`

人类在这一步要确认：

- 一个 task 是否够小，能在一条分支上安全推进
- 依赖关系是否清楚
- task 文件里的 `Implementation Plan` 和 `Validation Plan` 是否已经足够让后续直接执行

## 阶段 4：审核 task plan，再开始编码

现在 `$gstack2task` / `$issue2task` 产出的 task 文件，本身就应该包含可以直接执行的实现方案。

人工路径里，这一步的人类职责是：

- 审核实现方向是不是你真正想要的
- 纠正过度设计或漏掉的边界
- 决定是否要继续补跑 `$plan-eng-review` 或 `$autoplan`

如果你不接受这个方案，就不应该进入编码。

## 阶段 5：实现、精简、提交节奏由人来控

这一步没有单一 skill 替你“自动到底”。你自己决定什么时候：

- 开始实现
- 什么时候适合先跑 `$simplify`
- 什么时候做普通 commit
- 什么时候只做一次 `$checkpoint`

人工路径的优势是节奏细。你可以：

- 先做一小块实现
- 手动验证
- 再决定是否继续扩 patch

代价是你自己必须承担每个中间判断。

## 阶段 6：设计、代码、浏览器验证逐步过门禁

### `$design-review`

只有在 task 涉及用户可见 UI 时才需要。人工路径里，你通常会在这里亲自看截图、看修复方向、看视觉质量，而不是默认自动接受所有修补。

### `$review`

这是结构性代码审查。人在这里最重要的职责是区分：

- 真正要修的结构问题
- 可以接受的实现取舍
- 是否需要扩大修正范围

### `$qa`

这里是用户流程验证门禁。人工路径里，人类通常会更积极地决定：

- 哪些 bug 是 must-fix
- 哪些可以留到后续 task
- 是否需要继续追加验证范围

## 阶段 7：`$checktask` 做验收，而不是第一次收口代码

人工路径里，`$checktask` 不是“顺手看看”。它应该发生在你已经基本完成实现和验证之后。

人在这一步要明确判断：

- 验收标准是否真的通过
- task 文档是否和实际实现一致
- 相关 `memory/` 或局部 docs 是否需要同步

如果还有缺口，这一步就应该停住，而不是硬往发布走。

## 阶段 8：正式发布仍然是独立门禁

### `$ship`

人在这里需要关注：

- 分支是不是 ready to ship
- review readiness 是否够新
- 版本号、CHANGELOG、测试和 PR 是否匹配当前 diff

### `$land-and-deploy`

人在这里决定是否真正 land 到主干，并在部署验证阶段判断：

- 现在是不是适合 merge
- 部署后的结果是否健康
- 需要不要回滚或继续观察

### `$document-release`

这一步不是“顺手补文档”，而是确保 repo 级文档真的和 shipped changes 同步。它通常接在 `$ship` 后，也可以按仓库发布方式放在 `$land-and-deploy` 前后补齐。

## 阶段 9：复盘是可选，但对长期流程很有价值

`$retro` 不属于单个 feature 的强制步骤，但如果团队在意流程质量，它能帮助人类复盘：

- 本周到底交付了什么
- 哪些步骤最耗时间
- 哪些模式在重复出问题

## 这条路径里的分支和 git 规则

- `main/master` 更适合作为初始化与上游规划的起点。
- `gstack2task` / `issue2task` 会把执行切入 task 分支，并在 task 文件中写入初版实现计划。
- 审核 task plan、实现、`simplify`、`checkpoint`、`design-review`、`review`、`qa`、`checktask`、`ship` 都应围绕当前 task 分支推进。
- `$land-and-deploy` 是进入主干的门禁，不应提前被偷偷替代。
- `design-review` 和 `qa` 需要 clean working tree；所以在它们之前，人必须先把手头改动收成稳定状态。

## 为什么这条路更适合高控制度团队

因为它允许人类在更多节点行使判断权：

- 先不急着自动推进
- 在每个阶段门禁处明确过 / 不过
- 把 scope、质量、风险、发布时间都控制在可解释的决策里

代价也很明确：更慢、更费人，但适合复杂场景。

## 推荐读法

- 想要更省人工、更安全地自动推进：看 [半自动开发流程](semi-auto-workflow.md)。
- 想查每个 skill 的内部流程、产物和前置状态：看 [Skill 详细手册](skill-reference.md)。
