# Codev Skills

一组面向 Codex 的自定义 skills，用来管理开发过程内部细节：整理需求、把上游规划落成任务、规划实现、验收任务、构建项目记忆体系、提交轻量发布，以及对 diff 做语义不变的精简重构。默认可单独使用，也可以和 gstack 搭配工作。

## 安装

仓库可以 clone 到任意目录，安装通过 `./setup` 完成：

```bash
git clone git@github.com:wmzhai/codev.git
cd codev
./setup
```

`./setup` 会把当前仓库安装到 `~/.codex/skills/`，并建立受管 skills 的链接：

```text
~/.codex/skills/
├── codev -> /path/to/your/clone
├── memorize -> codev/skills/memorize
├── issue2task -> codev/skills/issue2task
├── gstack2task -> codev/skills/gstack2task
├── plantask -> codev/skills/plantask
├── checktask -> codev/skills/checktask
├── simplify -> codev/skills/simplify
└── ships -> codev/skills/ships
```

`setup` 目前受管的 skill 列表是 `memorize`、`issue2task`、`gstack2task`、`plantask`、`checktask`、`simplify`、`ships`。

## 调用方式

Codex skills 支持两种常见使用方式：

1. 显式调用：直接在提示里写 `$skill-name`
2. 语义触发：描述足够明确时，系统可能自动选择合适 skill

推荐优先使用显式调用，尤其是有副作用或目标很明确的 skill。

示例：

```text
$memorize
$issue2task
$gstack2task
$issue2task 42
$issue2task 修复结算页在空购物车时的 500 报错，并补齐空状态
$gstack2task ~/.gstack/projects/my-project/diweiming-main-implementation-plan-20260322-105643.md
$plantask T05
$checktask
$memorize
$ships
$ships v1.2.3
```

## 两种工作流

`codev` 有两条推荐主线：

- 纯 `codev`：适合老项目、需求已经比较明确、只想在 repo 内管理任务与记忆，不依赖 gstack。
- `codev + gstack` 协同：适合还需要上游问题定义、设计/工程评审、test plan、QA、PR gate 和 repo 级文档同步的项目。

### 纯 codev 工作流

这条线可以完全脱离 gstack 运行。

- 不依赖 `~/.gstack/projects/`
- 不依赖 `/office-hours`、`/plan-*`、`/qa`、`/ship`
- 任务入口统一走 `$issue2task`
- 验证主要依赖项目现有测试、人工验收和 `$checktask`
- 发布默认走 `$ships`

#### 默认主线流程

```text
$memorize
  ├─ writes AGENTS.md
  └─ writes memory/
       ├─→ $issue2task
       ├─→ $plantask
       └─→ $checktask
  ↓
$issue2task
  ├─ reads GitHub issue / 用户直接需求
  └─ writes tasks/Txx-*.md + switches to a new branch
       └─→ $plantask
  ↓
$plantask
  ├─ reads tasks/Txx-*.md
  └─ outputs implementation plan in-chat
  ↓
实现 + 项目内测试 / 人工验证
  ↓
$checktask
  ├─ reads tasks/Txx-*.md + code + 必要测试结果
  ├─ writes tasks/done/Txx-*.md
  └─ updates memory/ + 与本 task 直接相关的局部 docs/
  ↓
$memorize   (仅当结构、导航、约束真的变了)
  ├─ refreshes AGENTS.md
  └─ refreshes memory/
  ↓
$ships
  ├─ commits current branch
  ├─ pushes current branch
  └─ may create/push tag
```

#### 每一步怎么用

1. 先站在你想作为基线的分支上，通常是最新的 `main`
   - `issue2task` 会在当前 `HEAD` 上先新建并切到任务分支，再写 `tasks/`。
   - 所以开始前最好先把主线同步到你认可的最新状态。

2. 跑 `$memorize`
   - 新项目、长时间没维护、目录结构刚改过时，先跑一次。
   - 目标是把 `AGENTS.md` 和 `memory/` 刷到能支撑后续 task 化和实现。

3. 跑 `$issue2task`
   - 适用场景：需求已经在 GitHub issue 里，或者你手里已经有一段明确的自然语言需求。
   - 常见调用：
     - `$issue2task 42`
     - `$issue2task 修复结算页空购物车时的 500，并补齐空状态`
   - 结果：先切新分支，再写 `tasks/Txx-*.md`。一个输入源默认只生成一个任务；如果确实需要拆成多个任务，也还是只切一次新分支。

4. 跑 `$plantask`
   - 只在 task 内容已经稳定时使用。
   - 它会把 `tasks/Txx-*.md` 压成可执行的实施方案，但这一步不改代码。
   - 如果你还在讨论需求范围，不要过早跑 `plantask`。

5. 实现 + 项目自己的测试 / 人工验证
   - 这一步不靠 codev 规定具体命令，按项目已有测试方式走。
   - 推荐先把 task 做到“可验证的一个完整状态”，再进入 `$checktask`，不要边写边验收。

6. 跑 `$checktask`
   - 使用时机：你认为 task 已经实现完成，准备按验收标准逐条关项。
   - 它会验证 `tasks/Txx-*.md`、更新 checkbox、必要时按真实结果回写任务文案，把完成项归档到 `tasks/done/`，并同步 `memory/` 与本任务直接相关的局部 `docs/`。
   - 它不是 repo 级 release 文档同步器；`README.md`、`CHANGELOG`、`VERSION` 这类不应指望它顺手兜底。

7. 跑 `$ships`
   - 适用场景：你只想做轻量 `commit + push`，或者再加一个版本 tag。
   - 它会处理当前分支的全部已改动文件，不做选择性过滤。
   - 它不会创建 PR，也不会把分支合并回 `main`。

#### 纯 codev 的分支与 main 策略

- 默认切分支时机：`$issue2task`。这个 skill 会在写入任何 task 文件之前先新建并切到任务分支。
- 默认分支粒度：一个输入源一条任务分支；如果一个输入源拆成 `T12a` / `T12b` / `T12c`，也还是同一条新分支。
- 默认实现位置：`$plantask`、实现、测试、`$checktask`、`$ships` 都继续在这条任务分支上完成。
- `$ships` 只负责把当前分支提交并推到远端，不负责合并到 `main`。
- 合并回 `main` 的时机：当前任务在分支上已经验收完，并且你自己的 review / PR 流程已经完成之后。纯 codev 不接管这一步，按你所在仓库自己的 git/平台流程合并。
- 合并回 `main` 之后，推荐马上切回 `main` 并同步最新主线，再开始下一轮 `$issue2task`。不要在旧任务分支上继续派生下一轮任务。

#### 适用场景

- 老项目，没有 gstack 使用习惯
- 需求已经在 GitHub issue 或口头描述里比较明确
- 你只想把需求压成 `tasks/`，做实现规划、验收和轻量发布
- 这次变更不需要额外的产品评审、设计评审、test plan 或 PR gate

#### 这条线的边界

- `codev` 会负责 `tasks/`、`AGENTS.md`、`memory/` 和任务收口
- `codev` 不会替代 gstack 产出 feature 级 design doc、test plan、QA 报告或 PR review gate
- 如果后续某个需求需要更重的 planning 或 QA，可以从这条线切换到下面的协同工作流，不冲突

### codev + gstack 协同工作流

当两个仓库一起用时，推荐把它们视为两层系统：

- gstack：负责上游问题定义、产品/设计/工程评审、测试计划、QA、ship、repo 级人类文档同步。
- codev：负责把上游输入压成 `tasks/`、围绕 `tasks/` 做实现规划与验收、维护 `AGENTS.md` 与 `memory/`。

#### 先记住的硬依赖

- `/office-hours` 产出的 design doc 是 `/plan-ceo-review` 和 `/plan-eng-review` 最重要的上游输入。没有 design doc 时，这两个 skill 都会先建议你回去跑 `/office-hours`。
- `/design-consultation` 会写 `DESIGN.md`；`/plan-design-review` 会用 `DESIGN.md` 校准设计决策。对“新 UI / 还没有设计系统”的项目，推荐顺序是先 `/design-consultation`，再 `/plan-design-review`。
- `/plan-eng-review` 会把 test plan 写到 `~/.gstack/projects/`；`/qa` 和 `/qa-only` 会优先消费这份 test plan，而不是只靠 git diff 猜。
- `/ship` 会在创建 PR 后自动调用 `/document-release`；如果你已经决定走 gstack `/ship`，通常就不需要再手工单独跑 `/document-release`。
- `issue2task` 和 `gstack2task` 是两个平行入口，不互相替代：
  - GitHub issue 或直接需求：`$issue2task`
  - `~/.gstack/projects/` 下的 design doc / test plan / handoff：`$gstack2task`

#### 默认主线流程

下图把“步骤”和“文件工件”拆开画；凡是单独列出来的路径，都是后续步骤会实际读取的输入。

```text
$memorize
  ├─ writes AGENTS.md
  └─ writes memory/
       ├─→ $gstack2task
       ├─→ $plantask
       └─→ $checktask
  ↓
/office-hours
  └─ writes ~/.gstack/projects/<slug>/*-design-*.md
       ├─→ /plan-ceo-review
       ├─→ /plan-eng-review
       └─→ $gstack2task
  ↓
/plan-ceo-review
  ├─ reads ~/.gstack/projects/<slug>/*-design-*.md
  ├─ appends ~/.gstack/analytics/review-log.jsonl
  └─ may write ~/.gstack/projects/<slug>/<user>-<branch>-ceo-handoff-<datetime>.md
       └─→ /plan-ceo-review   (仅中断后恢复时回读)
  ↓
[有 UI 吗?]
  ├─ 否 → 跳过设计支线
  └─ 是
      ↓
      [已有 DESIGN.md 吗?]
        ├─ 否 → /design-consultation
        │       ├─ writes DESIGN.md
        │       └─ updates CLAUDE.md
        │            ├─→ /plan-design-review
        │            ├─→ /design-review
        │            ├─→ /review
        │            └─→ /ship
        └─ 是 → 直接沿用现有 DESIGN.md + CLAUDE.md
      ↓
      /plan-design-review
        ├─ reads 当前 plan + DESIGN.md + CLAUDE.md + TODOS.md
        ├─ edits 当前 plan 文件
        └─ appends ~/.gstack/analytics/review-log.jsonl
             └─→ /ship   (review readiness gate)
  ↓
/plan-eng-review
  ├─ reads ~/.gstack/projects/<slug>/*-design-*.md
  ├─ reads 已收敛后的当前 plan
  ├─ writes ~/.gstack/projects/<slug>/*-test-plan-*.md
  │    ├─→ /qa
  │    ├─→ /qa-only
  │    └─→ $gstack2task
  └─ appends ~/.gstack/analytics/review-log.jsonl
       └─→ /ship   (review readiness gate)
  ↓
$gstack2task  或  $issue2task
  ├─ $gstack2task reads ~/.gstack/projects/<slug>/*-design-*.md
  ├─ $gstack2task reads ~/.gstack/projects/<slug>/*-test-plan-*.md
  ├─ $gstack2task may read ~/.gstack/projects/<slug>/*-implementation-plan-*.md
  ├─ $issue2task reads GitHub issue / 用户直接需求
  └─ writes tasks/Txx-*.md + switches to a new branch
       └─→ $plantask
  ↓
$plantask
  ├─ reads tasks/Txx-*.md
  └─ outputs implementation plan in-chat
  ↓
实现
  ├─ 遇到根因不清的 bug → /investigate
  ├─ 有已实现 UI 要做视觉审查 → /design-review
  │    ├─ reads DESIGN.md   (if present)
  │    └─ writes .gstack/design-reports/...
  ├─ 结构与风险审查 → /review
  │    ├─ reads current diff (+ DESIGN.md if present)
  │    └─ appends ~/.gstack/analytics/review-log.jsonl
  │         └─→ /ship   (review readiness gate)
  └─ 浏览器验证 → /qa 或 /qa-only
       ├─ reads ~/.gstack/projects/<slug>/*-test-plan-*.md
       ├─ writes .gstack/qa-reports/qa-report-{domain}-{YYYY-MM-DD}.md
       └─ writes .gstack/qa-reports/screenshots/
  ↓
$checktask
  ├─ reads tasks/Txx-*.md + code + 必要测试结果
  ├─ writes tasks/done/Txx-*.md
  └─ updates memory/ + 与本 task 直接相关的局部 docs/
  ↓
$memorize   (仅当结构、导航、约束真的变了)
  ├─ refreshes AGENTS.md
  └─ refreshes memory/
  ↓
/ship
  ├─ reads ~/.gstack/analytics/review-log.jsonl
  ├─ reads ~/.gstack/projects/<slug>/<branch>-reviews.jsonl
  ├─ creates PR
  └─ auto /document-release
       └─ updates README.md / CHANGELOG / VERSION / CLAUDE.md / CONTRIBUTING.md / TODOS ...
  ↓
/retro
```

#### 每一步怎么用

1. 先确定你要以哪条分支作为实现基线，通常是最新的 `main`
   - gstack 的 planning skills 主要产出 `~/.gstack/projects/` 下的外部工件；真正把 repo 内执行单元落到当前仓库，是从 `$gstack2task` 或 `$issue2task` 开始。
   - 这两个 task-entry skills 会在当前 `HEAD` 上先切新分支，所以如果你希望实现从 `main` 开始，就先把 `main` 同步好。

2. 跑 `$memorize`
   - 作用和纯 codev 模式一样：先把 repo 内长期记忆层补齐。
   - 后面的 `$gstack2task`、`$plantask`、`$checktask` 都会依赖这些 repo 事实。

3. 跑 `/office-hours`
   - 适用场景：新功能、范围还没锁、需要先把问题定义讲清楚。
   - 产物：`~/.gstack/projects/<slug>/*-design-*.md`
   - 这一步写的是 feature 级 design doc，不是 repo 级 README。

4. 跑 `/plan-ceo-review`
   - 用来先锁产品边界和 scope。
   - 如果 scope 还不稳，不要急着 task 化；否则后面设计和工程方案都会返工。

5. UI 相关分支：先 `/design-consultation`，再 `/plan-design-review`
   - 当项目还没有 `DESIGN.md` 且这次改动涉及 UI/UX 时，先跑 `/design-consultation` 生成 `DESIGN.md`，必要时也会更新 `CLAUDE.md`。
   - 然后跑 `/plan-design-review`，让它按 `DESIGN.md` 校准交互、层级、响应式和视觉一致性。
   - `plan-design-review` 是计划阶段的设计审查；skill 自己也明确要求，在实现完成后再跑 `/design-review` 做视觉 QA。

6. 跑 `/plan-eng-review`
   - 这一步放在 CEO 和设计收敛之后。
   - 产物：`~/.gstack/projects/<slug>/*-test-plan-*.md`
   - 后面的 `/qa`、`/qa-only` 会优先读这份 test plan，而不是只靠 diff 猜要测什么。

7. 跑 `$gstack2task` 或 `$issue2task`
   - 这是默认的“切实现分支”时机。
   - 如果输入已经沉淀在 `~/.gstack/projects/`：用 `$gstack2task`
   - 如果输入还是 GitHub issue 或你手写需求：用 `$issue2task`
   - 两者都会在写 `tasks/Txx-*.md` 之前先创建并切到新分支。

8. 跑 `$plantask`
   - 作用：把 repo 内 task 文档压成单任务实施方案。
   - 使用时机：task 已稳定、准备真正开写代码时。

9. 进入实现与验证循环
   - `/investigate`
     - 用在 bug 根因不清楚时，先查原因，再修。
   - `/design-review`
     - 只在“已经有可运行页面”时使用。
     - 如果当前在 feature branch 且没给 URL，它会自动进入 diff-aware mode，按 `git diff main...HEAD` 推断受影响页面。
     - 如果当前在 `main/master` 且没给 URL，它会直接要求你提供 URL。
     - 无论在哪条分支上，worktree 必须是干净的；它会为每个设计修复单独 commit，所以实操上最好先把当前实现 checkpoint commit 好，再跑 `/design-review`。
   - `/review`
     - 在 diff 已成形、准备进入发布前检查时跑。
     - 它更偏结构风险、边界条件、trust boundary，不是视觉 QA。
   - `/qa` / `/qa-only`
     - 在页面已可运行、关键功能已落地时跑。
     - 如果前面有 `/plan-eng-review` 产出的 test plan，这里会优先消费它。

10. 跑 `$checktask`
   - 放在验证循环之后。
   - 它负责按 task 文档收口，而不是替代 `/ship` 处理 PR 和 repo 级发布文档。

11. 只在必要时再跑 `$memorize`
   - 目录结构、共享规则、导航入口真的变了再刷新。
   - 纯实现细节变化通常不需要机械重跑。

12. 跑 `/ship`
   - 这是协同工作流里的正式发布入口。
   - 它会检查 review readiness、把最新 base 分支合到当前 feature branch、重新跑测试、推送分支并创建 PR，然后自动接 `/document-release`。
   - 如果你只想做轻量 `commit/push/tag`，才退回用 `$ships`。

#### 协同模式的分支与 main 策略

- 默认切分支时机：`$gstack2task` 或 `$issue2task`。这两个 skill 会在写 task 文件之前先新建并切到任务分支。
- 默认实现位置：从 task 化开始，到 `$plantask`、实现、`/design-review`、`/review`、`/qa`、`$checktask`、`/ship`，都留在这条 feature branch 上完成。
- `/design-review` 最适合在 feature branch 上跑：
  - 不给 URL 时可以用 diff-aware mode。
  - 它会为每个修复单独 commit，所以不应在脏工作区里跑。
  - 技术上在 `main` 上给 URL 也能继续，但不推荐，因为这些原子修复 commit 会直接落在主线。
- `/ship` 必须从 feature branch 运行；如果你站在 base branch / 默认分支上，它会直接 abort。
- `/ship` 在发布前会先把最新的 base branch merge 到当前 feature branch 再测试。这一步是“把主线更新合进功能分支”，不是“把功能分支合回主线”。
- `/ship` 会 push 当前分支并创建 PR，但不会自己完成最终的 branch merge。真正合并到 `main` 的时机，是 PR 审核通过、按仓库既有规则落地的时候。
- 分支已经合进 `main` 之后，再切回 `main` 同步最新主线，然后开始下一轮 planning / task 化。不要在已经 ship 完的旧 feature branch 上继续叠下一个需求。

#### 设计相关两个 skill 的使用边界

- `/plan-design-review`
  - 用在实现前。
  - 输入是 plan、`DESIGN.md`、`CLAUDE.md` 等文档和上下文。
  - 不要求你先有可运行 URL。
  - 目标是把设计方案补到足够完整，避免实现后大返工。

- `/design-review`
  - 用在实现后。
  - 输入是正在运行的页面，以及当前 feature branch 的真实 UI。
  - 要求 clean working tree；如果在 `main/master` 上还必须提供 URL。
  - 目标是视觉 QA + 原子修复 commit，不适合在半成品状态下过早运行。

#### 协同模式下最常见的三种实际走法

#### A. 新功能，且已经用 gstack 做过完整 planning

`$memorize` → `/office-hours` → `/plan-ceo-review` → `(/design-consultation)` → `(/plan-design-review)` → `/plan-eng-review` → `$gstack2task` → `$plantask` → 实现 → `(/design-review)` → `/review` → `/qa` → `$checktask` → `($memorize)` → `/ship` → `/retro`

#### B. 需求本来就在 GitHub issue 里

`$memorize` → `$issue2task` → `$plantask` → 实现 → `/review` → `/qa` → `$checktask` → `($memorize)` → `/ship`

#### C. 纯 debug / 修 bug

`$memorize` → `/investigate` → 如需补 task 再走 `$issue2task` 或 `$gstack2task` → `/review` → `/qa` → `$checktask` → `/ship`

## 与 gstack 搭配时的职责边界

推荐把两边的职责固定成两层，不要双写：

- gstack 负责上游产品与工程评审、测试计划、QA、ship、repo 级人类文档同步。
- codev 负责把需求或 gstack 工件收敛成 `tasks/`、围绕 `tasks/` 做实现规划与验收、维护 `AGENTS.md` 与 `memory/`。
- `issue2task` 只处理 GitHub issue 或用户直接需求，不读取 `~/.gstack/projects/`。
- `gstack2task` 只处理 `~/.gstack/projects/` 下的 gstack 工件，不去查询 GitHub issue。
- `memorize` 维护 repo 事实和 Codex 记忆，但不删除 `CLAUDE.md` 中仍然服务宿主代理或 gstack 的兼容说明。
- `checktask` 可以更新 `memory/` 和任务直接相关的局部 `docs/`；`README.md`、`CHANGELOG`、`VERSION`、`CLAUDE.md`、`CONTRIBUTING.md`、`TODOS` 这类 repo 级文档优先交给 gstack `/document-release`。

## 下游项目文档约定

所有基于这组 skill 的下游项目，默认都应具备三类文档目录：

- `tasks/`：管理工作任务。这部分已经由 `issue2task`、`plantask`、`checktask` 这套流程直接消费和维护。
- `memory/`：管理面向 Codex 的检索型项目记忆，并与根目录的 `AGENTS.md` 一起构成项目记忆系统。`AGENTS.md` 负责高优先级规则、默认工作方式和最短入口；`memory/` 负责按主题组织长期知识、约束、排查路径和模块落点。Codex 了解项目，主要依赖这套记忆系统和具体代码，而不是依赖面向人类的说明文档。
- `docs/`：管理给人类阅读的说明文档，例如背景介绍、设计说明、使用手册、对外文档等。正常情况下 agent 不需要把它作为默认阅读入口。
- 如果项目已接入 gstack，`~/.gstack/projects/` 下的 design doc、handoff、test plan 是 repo 外的上游工件，不应手工复制到 `memory/`；需要转成 repo 内执行单元时，走 `$gstack2task` 写入 `tasks/`。

`AGENTS.md` 和 `memory/` 的配合方式建议如下：

- 阅读顺序上，默认先看 `AGENTS.md`，再按问题进入 `memory/`。前者用于快速建立当前仓库的工作边界，后者用于按主题继续检索。
- 内容分工上，`AGENTS.md` 只放高优先级、跨目录共享、几乎每次开始工作都需要先知道的规则和事实；`memory/` 则承接更细的模块知识、约束说明、排查路径、运行流程和目录落点。
- 写作目标上，`AGENTS.md` 追求短、硬、稳定，像“项目操作系统”；`memory/` 追求可检索、可扩展，像“项目知识索引”。
- 维护原则上，尽量不要在两处重复堆文案：能放在 `AGENTS.md` 的，应当是全局规则；需要按主题展开、未来会持续补充的，再放进 `memory/`。
- 使用方式上，Codex 应优先依赖 `AGENTS.md`、`memory/` 和实际代码理解项目；`docs/` 主要服务人类沟通，不承担默认机器记忆入口的职责。

下游项目推荐结构：

```text
project/
├── AGENTS.md
├── CLAUDE.md
├── tasks/
├── memory/
├── docs/
├── skills/
├── setup
├── test/
└── README.md
```

## Skills 一览

| Skill | 调用 | 说明 |
|------|------|------|
| `memorize` | `$memorize` | 为项目构建或刷新 `AGENTS.md` 与 `memory/` 记忆体系 |
| `issue2task` | `$issue2task` | 从 GitHub issues 或直接需求描述生成带依赖关系的任务文件 |
| `gstack2task` | `$gstack2task` | 从 `~/.gstack/projects/` 下的 gstack 工件生成任务文件 |
| `plantask` | `$plantask` | 基于任务文件和代码现状输出实现方案，并在结尾收口到“开始实现/继续讨论” |
| `checktask` | `$checktask` | 验收任务、更新 checklist、同步 `memory/` 与任务相关文档、归档已完成任务 |
| `ships` | `$ships` | 轻量提交并推送当前分支，可选创建 release tag |
| `simplify` | `$simplify` | 供 `checktask` 内部复用，或在无 task 时单独精简给定 diff |

## Skill 说明

### memorize

为新项目建立或为已有项目刷新面向 Codex 的记忆体系。它会系统分析项目结构，围绕根目录的 `AGENTS.md` 和 `memory/` 建立 Codex 的上手路径、问题路由、系统边界和更新落点；如果仓库里存在 `CLAUDE.md`，会把其中对 Codex 有价值的 repo 事实合并进 `AGENTS.md`，但保留仍然服务 Claude、gstack 或其它宿主代理的兼容块。

`memorize` 默认使用简体中文生成或刷新相关项目文档，避免把 `AGENTS.md`、`memory/` 或收敛后的 `CLAUDE.md` 写成英文默认稿。

常见用法：

```text
$memorize
```

适用场景：

- 新项目第一次补齐 Codex 记忆系统
- 仓库结构变化后刷新 `AGENTS.md` 和 `memory/`
- 想让新来的 Codex session 最快熟悉项目
- 需要重建“先读什么、问题去哪找、改动该落哪”的导航
- 需要把 `CLAUDE.md` 的 repo 事实合并进 `AGENTS.md`，同时保留宿主或 gstack 的兼容说明

默认会优先识别项目根目录、主要入口、共享层、业务层、调试入口和部署入口，再把这些信息整理成简短、可检索、可持续更新的文档结构。

### issue2task

读取一个或多个 GitHub issue，或直接接收用户附带的一段任务描述，结合代码现状先自行收敛需求，再生成 `tasks/Txx-*.md`。任务号默认按 `tasks/` 和 `tasks/done/` 中现有最大编号顺延；如果任务来自 issue，会在任务开头记录 issue 编号；写入前会先新建一个分支，默认用首个新任务文件名作为分支名。

常见用法：

```text
$issue2task
$issue2task 42
$issue2task #42
$issue2task --label backend
$issue2task 修复结算页在空购物车时的 500 报错，并补齐空状态
```

产出通常包括：

- `tasks/Txx-*.md`
- 新建分支，默认分支名与首个新任务文件同名

这个 skill 关注需求整理和任务拆分，不负责实现方案设计。`tasks/` 里不需要额外索引，任务文件名本身就是索引。默认会直接写出可交接的任务文件，只有阻塞性歧义才会中途提问；如果用户在 `$issue2task` 后面直接给了一段自然语言需求，就不会再去查 issue 列表；如果用户完全不带参数，则默认只处理当前仓库编号最小的 open issue，而不是批量处理全部 open issues。

### gstack2task

读取 `~/.gstack/projects/` 下与当前仓库相关的 design doc、implementation handoff、test plan 等工件，收敛成可执行的 `tasks/Txx-*.md`。

常见用法：

```text
$gstack2task
$gstack2task wyckoff
$gstack2task ~/.gstack/projects/wyckoff/diweiming-main-implementation-plan-20260322-105643.md
```

这个 skill 负责把 gstack 的上游规划压成 repo 内部任务，不查询 GitHub issue。默认优先读取当前仓库、当前分支下最新的 implementation handoff，再补充 test plan、design doc、CEO handoff 等上下文；如果 gstack 工件里已经有明确的实现边界和验证路径，应直接收敛到 `tasks/`，而不是重复做一轮高层产品讨论。

### plantask

读取 `tasks/` 中的待办任务，检查依赖是否完成，深入相关代码，输出可直接实施的计划。

常见用法：

```text
$plantask
$plantask T05
```

这个 skill 本轮只做规划，不会直接改代码。默认应一次性给出可执行方案，并在结尾主动问用户是接受后开始实现，还是继续讨论；用户接受后，下一轮直接进入实现，不需要重新把改动要求再说一遍。

### checktask

逐项核对任务文件中的验收标准，更新通过项的 checkbox；如果执行过程中实现已经变化，以已验证的实际结果同步任务文档；在流程末尾最多自动对本次相关 diff 做一次语义不变的精简，并按最新已验证内容更新 `memory/` 与任务直接相关的 `docs/`；全部通过时归档到 `tasks/done/`。

常见用法：

```text
$checktask
$checktask T04
```

它会优先做最小侵入验证，只在标准明确要求时运行测试或命令。遇到模糊标准时，应标记为需要人工确认，而不是猜测通过。如果用户在验收过程中修改了实现，导致 task 文案过期，应以已验证的实际结果为准回写相关任务内容，而不是强行要求实现继续贴合旧文案。验收步骤结束后，会在整个流程末尾最多自动调用一次 `simplify` 风格的本地精简，并顺带对与本任务直接相关的 `memory/` 和局部 `docs/` 做基于已验证事实的同步更新；`README.md`、`CHANGELOG`、`VERSION`、`CLAUDE.md`、`CONTRIBUTING.md`、`TODOS` 这类 repo 级文档默认交给 gstack `/document-release` 维护。

### ships

轻量提交当前工作区并推送当前分支；如果提供版本号，再创建并推送 tag。

常见用法：

```text
$ships
$ships v0.1.3
$ships v1.0.0-rc1
```

`ships` 是显式调用优先的 skill。当前配置下不会默认隐式触发。

如果仓库同时使用 gstack，默认应优先使用 gstack `/ship` 来处理 review gate、PR、测试覆盖和 repo 级文档同步；`$ships` 只适合明确想要轻量 `commit/push/tag` 时使用。

### simplify

针对给定 diff 做语义不变的精简重构，目标是降低嵌套、去重、改进局部命名、使用更惯用的写法，但不改变行为、不引入依赖、不改 API。它通常作为 `checktask` 的内部步骤自动执行；只有想单独精简某个 patch 时才显式调用。默认直接落地最小修改，并只返回简短摘要，不打印完整 patch 或大段源码。

常见用法：

```text
$simplify

<paste diff here>
```

如果没有直接给 diff，也可以让它基于当前 patch 进行精简。`checktask` 内部调用时，应直接复用已经确定的相关最小 diff，并且整个 `checktask` 流程里只调用一次；单独使用时，`simplify` 仍然是显式调用优先。除非用户明确要求查看 patch，否则结果应保持为摘要而不是代码回显。

## 测试安装脚本

可以运行下面的 smoke test 验证 `./setup` 的全新安装、幂等性和冲突处理：

```bash
./test/setup-smoke.sh
```

## 编写新 Skill

最小目录结构如下：

```text
skills/
└── my-skill/
    ├── SKILL.md
    └── agents/
        └── openai.yaml   # 可选
```

`SKILL.md` 最小模板：

```markdown
---
name: my-skill
description: 说明这个 skill 做什么，以及什么情况下应该使用它。
---

# My Skill

写清楚输入、工作流、约束和输出。
```

`agents/openai.yaml` 可用于定义 UI 元数据和调用策略，例如：

```yaml
interface:
  display_name: "my-skill"
  short_description: "一句中文简介"
  default_prompt: "使用 $my-skill 来完成某件事。"

policy:
  allow_implicit_invocation: false
```

说明：

- `name` 和目录名应保持一致。
- frontmatter 只需要 `name` 和 `description`。
- `description` 既要描述能力，也要描述“什么时候使用它”。
- 推荐 `display_name` 直接使用原始 skill 名；`short_description` 和 `default_prompt` 可继续使用中文。
- `allow_implicit_invocation: false` 表示这个 skill 只适合显式调用。
- 新 skill 默认放在 `skills/` 下，仓库根目录只保留仓库级文件、`memory/` 和测试。
