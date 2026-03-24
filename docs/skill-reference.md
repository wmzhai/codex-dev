# Skill 详细手册

这份文档是主链路 skill 的操作手册。它不重复讲“半自动路径”和“人工路径”怎么选，只回答这些问题：

- 这个 skill 负责什么
- 它实际会怎么推进
- 它读哪些输入、写哪些产物
- 它对 git 分支、clean tree、任务状态、上游工件、用户确认有什么前置要求
- 它跑完以后，下一个通常该接什么

如果你还没确定该走哪条路径，先读：

- [半自动开发流程](semi-auto-workflow.md)
- [人工深度参与流程](manual-workflow.md)

## 说明

- 本文覆盖 codev 主链路技能，以及 codev 明确依赖的 gstack 主链路技能。
- 对 codev 自有 skill，以下内容以本仓库 `skills/*/SKILL.md` 为准。
- 对 gstack skill，以下内容是 codev 侧依赖的外部行为契约总结，来源于本机已安装的 gstack skill 文档；它不是 gstack 全部内部实现的逐字复刻。
- 路径中的可选支线技能，例如 `cso`、`investigate`、`browse`、`canary` 等，不在本文主手册范围内；它们作为主链路的支持能力由上层 skill 间接调用。

## `$memorize`

Purpose: 刷新 repo 的 Codex 记忆层，让后续 session 先读对文件、遵守对的约束。

Typical trigger: 新项目初始化，或仓库结构、约束、目录边界已经发生变化。

Inputs / source of truth: 当前 repo 根目录、`README.md`、`AGENTS.md`、`CLAUDE.md`、`memory/`、项目入口文件和目录结构。

Preconditions: 需要一个可读的仓库根目录。没有 clean tree 硬要求。

Git / branch state: 任意分支可运行；它会改 repo 内文档，但不会自己 commit。

Reads prior outputs: 旧的 `AGENTS.md`、`memory/`、以及可能存在的 `CLAUDE.md`。

Execution flow:
1. 扫描 repo 根目录的入口文档和结构信号。
2. 判断当前项目的系统边界、热路径和默认工作流。
3. 收敛或重写 `AGENTS.md`。
4. 收敛或刷新 `memory/README.md` 与 `memory/core/*`。
5. 删除或改写过期记忆路径。

Produces / writes: `AGENTS.md`、`memory/README.md`、`memory/core/*` 及必要的领域记忆文档。

Success output: 一套与当前仓库真实状态对齐的记忆体系。

Stops / failure modes: 仓库根目录无法识别，或无法从实际代码中确认关键事实。

Next recommended steps: 上游规划、任务生成，或任何依赖仓库导航准确性的工作。

## `$office-hours`（gstack）

Purpose: 在实现前把问题定义、前提、备选方案和推荐方向压成一份设计文档。

Typical trigger: 需求还在探索期，或者没有足够好的 feature design doc。

Inputs / source of truth: 用户对问题和目标的描述、repo 当前上下文、可能存在的 `DESIGN.md`、当前分支上已有设计文档。

Preconditions: 可在 git repo 内运行；没有 clean tree 硬要求。

Git / branch state: 通常在 `main/master` 或当前规划分支上运行；不会改 repo 内代码。

Reads prior outputs: 同一 slug、同一分支下已有的 design doc；若有 `Supersedes:` 链，会沿旧文档取上下文。

Execution flow:
1. 通过 startup mode 或 builder mode 逼出真实问题和约束。
2. 必要时做线框或方向草图。
3. 形成推荐方案并让用户批准或带保留通过。
4. 把结果写成 design doc。

Produces / writes: `~/.gstack/projects/{slug}/{user}-{branch}-design-{datetime}.md`；可能还会有临时草图截图供后续引用。

Success output: 一份 branch 级设计文档，作为后续 CEO / Design / Eng review 的上游 source of truth。

Stops / failure modes: 用户仍在模糊探索、无法形成清晰问题定义，或浏览/设计辅助步骤需要额外确认。

Next recommended steps: `$autoplan`、`$plan-ceo-review`、`$plan-eng-review`。

## `$autoplan`（gstack）

Purpose: 自动串联 CEO、Design、Eng 三类 planning review，把能自动决策的部分直接处理掉。

Typical trigger: 已有设计文档或 plan，希望一次跑完整个 review gauntlet。

Inputs / source of truth: 当前分支的 design doc、当前 plan 文件、repo 当前上下文、CEO / Design / Eng review skill 文档。

Preconditions: 需要有可 review 的 plan；如果没有 design doc，通常会先建议 `$office-hours`。

Git / branch state: 一般在规划分支或准备进入实现前的当前分支运行；它会修改 plan 文件，但不做代码实现。

Reads prior outputs: 设计文档、已有的 review 日志和当前 plan 文本。

Execution flow:
1. 读取 CEO、Design、Eng review 的规则。
2. 顺序执行三类 review。
3. 用自身的自动决策原则处理中间问题。
4. 只把真正需要人拍板的 taste / scope / tradeoff 暴露出来。
5. 复用各 review 的正常产出路径。

Produces / writes: 修补后的 plan 文件；并复用 `$plan-ceo-review`、`$plan-design-review`、`$plan-eng-review` 各自的产物位置。

Success output: 一份完整 review 过的计划，以及 CEO / Design / Eng 的相关工件。

Stops / failure modes: 缺少基础 plan 或 design doc，或出现必须人工确认的关键决策。

Next recommended steps: `$gstack2task`、`$issue2task`，或在特定 task 分支补跑局部 planning review。

## `$plan-ceo-review`（gstack）

Purpose: 用 CEO / founder 视角重审 plan 的 ambition、scope 和产品方向。

Typical trigger: 有了 design doc 或初版 plan，但还没锁定 scope 和产品方向。

Inputs / source of truth: 当前 plan 文件、当前分支的 design doc、repo 系统审计上下文。

Preconditions: 需要一个可 review 的 plan；无 clean tree 硬要求。

Git / branch state: 可在 `main/master` 或 feature planning 分支运行；会写 plan 文件，不写实现代码。

Reads prior outputs: 当前分支最新 design doc、可能存在的 CEO handoff、已有 review 记录。

Execution flow:
1. 做系统审计和 design doc 检查。
2. 以选定的 scope mode 审查 plan。
3. 逐节指出 scope 扩展、收缩或重写建议。
4. 把关键判断写回 plan。
5. 额外输出 CEO review 工件。

Produces / writes: 当前 plan 文件；`~/.gstack/projects/{slug}/ceo-plans/{date}-{feature-slug}.md`。

Success output: 带 CEO 视角修订的 plan，以及独立的 CEO 计划工件。

Stops / failure modes: 没有 plan、没有足够上下文，或遇到必须人工选择的 scope 模式 / 战略分歧。

Next recommended steps: `$plan-eng-review`；如果 UI scope 明显，也可能建议 `$plan-design-review`。

## `$design-consultation`（gstack）

Purpose: 为有 UI 的项目生成一份 repo 根目录设计系统文档。

Typical trigger: 项目有明显 UI 范围，但还没有 `DESIGN.md`。

Inputs / source of truth: 产品定位、现有视觉上下文、repo 当前 UI 结构。

Preconditions: 适用于需要明确视觉系统的项目；不要求 clean tree。

Git / branch state: 一般在规划期运行；会改 repo 文档，但不是实现代码。

Reads prior outputs: 现有视觉规范或历史设计材料；如果已有 `DESIGN.md`，通常更偏向复盘或更新，而不是重复生成。

Execution flow:
1. 理解产品和视觉目标。
2. 定义字体、色彩、间距、布局、动效等设计系统决策。
3. 形成 repo 内的设计源文档。

Produces / writes: repo 根目录 `DESIGN.md`。

Success output: 一份后续 planning、design review、实现阶段都可以引用的设计系统 source of truth。

Stops / failure modes: 项目几乎无 UI、视觉方向完全未定，或用户不准备先锁设计系统。

Next recommended steps: `$plan-design-review`、`$plan-eng-review`、实现阶段的 `$design-review`。

## `$plan-design-review`（gstack）

Purpose: 在实现前审查 plan 的 UI / UX 决策完整度，并把缺失决策补回 plan。

Typical trigger: plan 含明显 UI scope，需要在编码前把设计决策补齐。

Inputs / source of truth: 当前 plan 文件、`DESIGN.md`、当前分支的 design doc、repo 现有 UI 模式。

Preconditions: 只有 plan 有 UI scope 时才有意义；纯后端计划会直接判定“不适用”。

Git / branch state: 在当前计划分支运行；它会写 plan 文件，不写实现代码。

Reads prior outputs: `DESIGN.md`、当前分支的 design doc、旧的 design review 记录。

Execution flow:
1. 先判断 plan 是否真的有 UI scope。
2. 读取 design system 和现有 plan。
3. 按多维设计完整度打分。
4. 把缺失的 hierarchy、state、interaction、responsive、accessibility 等决策写回 plan。
5. 记录本次 design review 状态与分数。

Produces / writes: 当前 plan 文件；review log；设计评分与决策记录。

Success output: 一份更完整的 UI 计划，而不是实现代码。

Stops / failure modes: plan 无 UI scope，或遇到必须人工回答的真实设计分歧。

Next recommended steps: `$plan-eng-review`，或在 plan 已足够稳定后进入 task 生成。

## `$plan-eng-review`（gstack）

Purpose: 在实现前锁定架构、失败模式、覆盖面和测试计划。

Typical trigger: plan 即将进入 task 化和编码，需要工程门禁。

Inputs / source of truth: 当前 plan 文件、当前分支 design doc、`DESIGN.md`、repo 当前架构和测试环境。

Preconditions: 需要可 review 的 plan；如无 design doc，通常会先建议 `$office-hours`。

Git / branch state: 在当前规划分支运行；写 plan 文件和测试计划，不写实现代码。

Reads prior outputs: design doc、已有 design / CEO review、现有测试基础设施和 TODO。

Execution flow:
1. 做系统审计、复杂度检查、设计文档检查。
2. 审查架构、代码组织、测试、性能和失败模式。
3. 画 coverage / codepath diagram。
4. 把关键 engineering 决策写回 plan。
5. 生成可供 `$qa` / `$qa-only` 消费的测试计划工件。

Produces / writes: 当前 plan 文件；`~/.gstack/projects/{slug}/{user}-{branch}-eng-review-test-plan-{datetime}.md`。

Success output: 更工程化的 plan，加上一份正式测试计划。

Stops / failure modes: 缺 plan、缺基础上下文、复杂度或 scope 分歧需要人拍板。

Next recommended steps: `$gstack2task`，或在特定 task 分支补跑局部 eng review。

## `$issue2task`

Purpose: 把 GitHub issue 或直接需求结合当前代码压成 repo 内 task plan 文件。

Typical trigger: 需求来自 issue、工单或用户直接描述，而不是 gstack 上游工件。

Inputs / source of truth: GitHub issue 内容或用户直接需求、当前代码现状。

Preconditions: 需要 git repo；如果要读 issue，还需要 `gh` 可用。

Git / branch state: 没有 clean tree 硬要求，但当前 `HEAD` 会成为新 task 分支的基底，最好从稳定状态开始。

Reads prior outputs: 现有 `tasks/` 与 `tasks/done/`，用于编号顺延和避免重复映射。

Execution flow:
1. 读取 issue 或直接需求。
2. 结合代码收敛范围、验收标准和依赖。
3. 继续基于真实代码写出 `Implementation Plan` 与 `Validation Plan`。
4. 决定要不要拆成多个 task。
5. 计算新任务编号。
6. 为每个 task 新建并切换到独立分支。
7. 写入 `tasks/T{nn}-{slug}.md`。

Produces / writes: 一个或多个 `tasks/T{nn}-{slug}.md`；对应的新分支。

Success output: repo 内可执行的 task 文件，已经包含需求边界、相关代码、实现计划和验证计划，用户审核后即可直接执行。

Stops / failure modes: 需要 issue 但 `gh` 不可用，或存在无法安全假设的关键需求歧义。

Next recommended steps: 先审核 task plan；认可后走手动实现链或直接进入 `$autodev`。

## `$gstack2task`

Purpose: 把 gstack 上游工件结合当前代码压成 repo 内 task plan 文件。

Typical trigger: 已经跑过 `$office-hours`、`$plan-*`、`$autoplan`，需要落到 `tasks/`。

Inputs / source of truth: `~/.gstack/projects/{slug}/` 下的 implementation plan、test plan、design doc、CEO handoff 等工件。

Preconditions: 需要 git repo，且 `~/.gstack/projects/` 存在可用工件。

Git / branch state: 没有 clean tree 硬要求，但当前 `HEAD` 会成为新 task 分支的基底，最好从稳定状态开始。

Reads prior outputs: 现有 `tasks/` 与 `tasks/done/`，以及对应 gstack project 目录。

Execution flow:
1. 定位 project slug 和相关工件。
2. 以 implementation / test plan 为主，design / CEO 工件为补充。
3. 深读相关代码，把上游边界映射到 repo 的真实入口。
4. 为每个 task 写出 `Implementation Plan` 与 `Validation Plan`。
5. 收敛成一个或多个可独立执行的 task。
6. 编号顺延。
7. 为每个 task 新建独立分支并写入任务文件。

Produces / writes: 一个或多个 `tasks/T{nn}-{slug}.md`；对应的新分支。

Success output: repo 内 task 已建立，既保留了上游规划中的关键边界和测试重点，也把实现落点压成了可直接执行的 plan。

Stops / failure modes: project slug 无法定位、工件冲突严重、或 `~/.gstack/projects/` 不存在。

Next recommended steps: 先审核 task plan；认可后走手动实现链或直接进入 `$autodev`。

## `$autodev`

Purpose: 在已有 task 分支上自动完成单个 task 的 plan 校准、实现、验证、分支部署和 task 文档持续维护。

Typical trigger: 当前 task 后面的 downstream 流程已经比较固定，希望自动推进到“已部署待人工确认”。

Inputs / source of truth: `tasks/T{nn}-{slug}.md`、当前代码、task 分支、已有规划结果、repo 部署能力。

Preconditions: 必须存在待办 task；前置依赖任务已完成；仓库支持非主干分支部署或等价验证环境。

Git / branch state: 可从 `main/master` 启动，它会切到 task 分支；运行过程中会改代码、改 task 文档、创建提交、推送分支；最终不 merge 主干。

Reads prior outputs: task 文件中的 `Implementation Plan` / `Validation Plan`、相关 gstack review / QA 结果、部署配置。

Execution flow:
1. 选择 task，必要时切到 task 分支。
2. 检查依赖任务和分支部署前提。
3. 初始化 task 文档中的执行记录区。
4. 先读取并校准 task 中已有的 `Implementation Plan` / `Validation Plan`，必要时写回 task 文档。
5. 分阶段实现、精简、提交、验证。
6. 视情况复用 `simplify`、`checkpoint`、`design-review`、`review`、`qa`。
7. 部署当前分支并做部署后验证。
8. 持续更新 task 文档，最终停在“已部署待人工确认”。

Produces / writes: 代码变更；更新后的 `tasks/T{nn}-{slug}.md`；中间提交与 push；非主干部署结果；可能还有被复用 skill 产生的截图、review log、测试记录。

Success output: 一个已部署、已验证、待人工确认的 task 分支，以及完整记录执行事实的 task 文档。

Stops / failure modes: 缺权限、缺凭证、缺分支部署能力、依赖任务未完成、或出现无法安全默认选择的高影响修复路径。

Next recommended steps: 人工确认部署结果；确认后运行 `$automerge`。如果不走半自动路径，也可以继续在当前 task 分支手动实现 / 验证。

## `$simplify`

Purpose: 在不改语义的前提下收窄当前 patch。

Typical trigger: 准备第一次提交、准备 clean tree、或 `checktask` 流程末尾要做一次语义不变精简。

Inputs / source of truth: 当前 diff 或用户明确指定的 patch 范围。

Preconditions: 需要有可精简的未提交 diff。

Git / branch state: 运行在当前工作区；不要求 clean tree；不提交、不推送。

Reads prior outputs: 当前 diff 及上下文。

Execution flow:
1. 读取 diff 与周边代码。
2. 找出重复逻辑、冗余分支、可安全内联或收窄的结构。
3. 做最小必要修改。
4. 返回精简结果摘要。

Produces / writes: 工作区代码变更。

Success output: 更小、更易审查、但语义等价的 patch。

Stops / failure modes: 没有可归属的 diff，或任何“简化”会引入行为风险。

Next recommended steps: 普通 commit、`$checkpoint`、`$design-review`、`$qa`、或 `$checktask`。

## `$checkpoint`

Purpose: 轻量提交并推送当前分支。

Typical trigger: 想要一个中间稳定点，或者下一步 skill 需要 clean working tree。

Inputs / source of truth: 当前工作区变更。

Preconditions: 工作区必须有要提交的变更。

Git / branch state: 运行在当前分支；不会改写历史；会 stage 全部变更并 push。

Reads prior outputs: 当前分支状态、当前 staged / unstaged diff。

Execution flow:
1. 检查当前分支与工作区状态。
2. `git add -A` 暂存全部改动。
3. 生成 conventional commit message。
4. 创建 commit。
5. 如果 hook 改了文件，再补一个普通 commit。
6. 推送当前分支。

Produces / writes: 新 commit、远端分支更新。

Success output: 一个已推送的稳定中间点。

Stops / failure modes: 工作区为空，或提交 / 推送失败。

Next recommended steps: `$design-review`、`$qa`、继续实现，或作为 `autodev` 的中间稳定点。

## `$design-review`（gstack）

Purpose: 对已经实现出来的 UI 做视觉 QA，并在必要时直接修复。

Typical trigger: task 涉及用户可见界面，且你想在发布前做一次设计质量门禁。

Inputs / source of truth: 当前实现的 UI、运行中的页面、可能存在的 `DESIGN.md`、当前分支 diff。

Preconditions: 需要可运行的界面；通常要求 clean working tree。

Git / branch state: 在当前 task 分支运行；会直接改代码，并把修复作为原子 commit 落在当前分支上。

Reads prior outputs: `DESIGN.md`、当前实现、现有 UI 模式。

Execution flow:
1. 打开页面并审视视觉一致性、层级、交互和 AI slop 风险。
2. 记录前后截图。
3. 逐轮修复视觉问题。
4. 对每轮修复做原子 commit 并重新验证。

Produces / writes: 代码修复、原子 fix commits、验证截图和 review 记录。

Success output: 一个视觉质量明显更稳的当前分支。

Stops / failure modes: UI 不可运行、工作区不干净、或浏览/验证基础能力缺失。

Next recommended steps: `$review`、`$qa`，或在问题较大时继续人工调整。

## `$review`（gstack）

Purpose: 做结构性 code review，重点看架构风险、SQL 安全、LLM trust boundary、条件副作用等。

Typical trigger: 当前分支的实现已基本稳定，准备进入更正式的验证和发布。

Inputs / source of truth: 当前分支 diff、代码上下文、基线分支。

Preconditions: 需要可审查的 branch diff。

Git / branch state: 在当前 task 分支运行；可能 auto-fix，但不应假定它会自动帮你创建最终 commit。

Reads prior outputs: 当前分支 diff、已有 review 记录。

Execution flow:
1. 读取当前 diff 和关键结构。
2. 识别高风险结构性问题。
3. 给出 findings，必要时直接修复局部问题。
4. 记录 review 状态。

Produces / writes: review 结论；可能有工作区代码改动或 review log。

Success output: 当前 diff 的结构性风险被显式暴露，必要的局部问题已修复。

Stops / failure modes: diff 不明确、上下文不足，或发现高影响问题需要人决定修复路径。

Next recommended steps: 手动验证修复、必要时补 commit，然后 `$qa`、`$checktask` 或 `$ship`。

## `$qa`（gstack）

Purpose: 用真实浏览器或近似真实用户流程测试来发现并修复缺陷。

Typical trigger: 当前分支实现已到“该按用户路径走一遍”的阶段。

Inputs / source of truth: 当前运行中的应用、已有测试计划、用户关键路径。

Preconditions: 需要应用可运行；通常要求 clean working tree。

Git / branch state: 在当前 task 分支运行；会修 bug，并把修复作为原子 commit 落在当前分支上。

Reads prior outputs: `~/.gstack/projects/{slug}/*-test-plan-*.md`、当前实现、已有 review 结果。

Execution flow:
1. 按测试计划或关键路径跑浏览器级 QA。
2. 记录问题、复现路径和风险级别。
3. 直接修复局部 bug。
4. 对修复做回归验证和原子 commit。

Produces / writes: bug 修复代码、原子 fix commits、QA 报告、截图或验证证据。

Success output: 关键用户路径通过，发现的主要缺陷已经在当前分支修复或被明确标记。

Stops / failure modes: 应用无法运行、工作区不干净、登录态 / 环境 / 浏览器条件缺失，或发现重大问题需要人重新定 scope。

Next recommended steps: `$checktask`、`$ship`，或继续手动修正。

## `$checktask`

Purpose: 逐项验证 task 验收标准，并同步 task、`memory/` 与任务相关文档。

Typical trigger: 当前 task 已经基本实现并完成必要验证，需要正式看它是否达标。

Inputs / source of truth: `tasks/T{nn}-{slug}.md`、当前实现、当前验证结果。

Preconditions: 需要目标 task 文件；如果依赖运行时验证，相关命令和环境必须可用。

Git / branch state: 在当前分支运行；不提交、不推送；可能更新 task、`memory/`、局部 docs；全部通过时会把任务移动到 `tasks/done/`。

Reads prior outputs: task 文件、当前代码、已有验证结果。

Execution flow:
1. 读取 task 验收标准。
2. 逐项验证并更新 checkbox。
3. 发现 task 文案与已验证现实不符时，按事实同步 task。
4. 全部通过则归档到 `tasks/done/`。
5. 在流程末尾最多做一次 `simplify` 式精简。
6. 同步 `memory/` 与任务相关 docs。

Produces / writes: 更新后的 task 文件；必要时 `tasks/done/` 归档；`memory/` 与局部 docs 更新。

Success output: 明确的验收状态，以及与实际实现对齐的 task 文档。

Stops / failure modes: 验收项未通过、环境不足以验证、或存在必须人工确认的标准。

Next recommended steps: 若仍有缺口，继续实现；若走人工发布路径，则 `$ship`。

## `$automerge`

Purpose: 在用户确认部署结果无误后，把 task 分支收口到主干，并处理版本号、正式发布和任务归档。

Typical trigger: `autodev` 已把当前 task 做到“已部署待人工确认”，用户已经明确放行。

Inputs / source of truth: 当前 task 文件、当前 task 分支、用户确认结论、仓库正式发布路径。

Preconditions: 用户必须已明确确认；目标 task 必须处于“已部署待人工确认”或等价状态。

Git / branch state: 在 task 分支运行；会改 task 文档、移动任务归档、merge 主干、处理版本号和正式发布。

Reads prior outputs: `autodev` 更新后的 task 文档、部署结果、现有 PR / 发布状态。

Execution flow:
1. 锁定目标 task 和当前分支。
2. 检查用户确认是否存在。
3. 再同步一次 task 文档，记录准备进入主干收尾。
4. 准备归档任务。
5. 进入正式发布路径，必要时复用 `$ship`、`$land-and-deploy`、`$document-release`。
6. 完成 merge、版本号、正式部署和归档。

Produces / writes: 归档后的任务文件；主干 merge；版本号 / tag；正式部署结果。

Success output: 任务已经从“分支上可确认”变成“主干上已正式发布”。

Stops / failure modes: 缺少用户确认、主干保护或 CI gate 不满足、PR / deploy 路径不可用。

Next recommended steps: 视需要运行 `$document-release` 或 `$retro`。

## `$ship`（gstack）

Purpose: 把当前 feature branch 收成 ready-to-merge 的 PR。

Typical trigger: 代码已准备进入正式发布链。

Inputs / source of truth: 当前 feature branch diff、base branch、测试环境、review readiness、`VERSION`、`CHANGELOG`、`TODOS.md`。

Preconditions: 必须运行在 feature branch；不能直接从 base branch 上跑；需要当前改动基本 ready。

Git / branch state: 会 merge base branch 到当前分支做测试、可能生成或补测试、更新 `VERSION` 和 `CHANGELOG`、拆分 / 创建 commits、push、创建 PR。

Reads prior outputs: 当前分支 diff、review log、测试基础设施、既有 `VERSION` / `CHANGELOG` / `TODOS.md`。

Execution flow:
1. 识别 base branch，并把 base merge 进当前分支。
2. 跑测试和 coverage 审计，必要时生成测试计划。
3. 处理 pre-landing review、lite design checks、Greptile 等 pre-PR 门禁。
4. bump `VERSION`。
5. 统一生成 `CHANGELOG`。
6. 组织 bisect-friendly commits。
7. push 分支。
8. 创建 PR，并同步 PR body。
9. 如配置允许，自动接上 `$document-release`。

Produces / writes: 新 commit、push、PR URL、`VERSION`、`CHANGELOG.md`、可能的测试计划工件、更新后的 PR body。

Success output: 一个可供 `$land-and-deploy` 接手的 PR。

Stops / failure modes: 在分支测试中发现未解决的 in-branch 失败、merge conflict 无法安全自动解决、关键 gate 未通过或版本决策需要人确认。

Next recommended steps: `$land-and-deploy`。

## `$land-and-deploy`（gstack）

Purpose: merge PR、等待 CI / 部署，并验证生产健康度。

Typical trigger: `$ship` 已创建 PR，准备正式 land。

Inputs / source of truth: PR、CI 状态、review 状态、部署配置、可选验证 URL。

Preconditions: 需要已存在的 PR；PR 必须可 merge；必要的 checks 和 approvals 必须最终通过。

Git / branch state: 一般从当前 feature branch 发起；会触发 PR merge，影响主干和正式部署，不是纯本地动作。

Reads prior outputs: `$ship` 生成的 PR、review log、PR body、文档 / 版本状态。

Execution flow:
1. 自动定位 PR 和 base branch。
2. 检查 PR 状态和 mergeability。
3. 等待 required checks。
4. 做 pre-merge readiness report。
5. merge PR。
6. 等待部署完成。
7. 调用 canary / 验证手段确认生产健康。

Produces / writes: 已 merge 的 PR、部署验证结果、可能的 canary 证据。

Success output: 当前 PR 已 land，且部署健康结论明确。

Stops / failure modes: 没有 PR、PR 已关闭、存在冲突、required checks 失败、部署验证失败或浏览能力未准备好。

Next recommended steps: `$document-release`，或在需要时继续观察 / 复盘。

## `$document-release`（gstack）

Purpose: 在 ship 后、merge 前后同步 repo 级文档，让文档和 shipped changes 对齐。

Typical trigger: 代码或 PR 已形成，需要把 README / ARCHITECTURE / CONTRIBUTING / CHANGELOG / VERSION / TODO 等文档收口。

Inputs / source of truth: 当前分支 diff、base branch、现有 repo 级文档、PR body、`CHANGELOG.md`、`VERSION`。

Preconditions: 必须在 feature branch 上运行；skill 文档明确说明如果在 base branch 上应直接停止。

Git / branch state: 会修改文档、必要时问版本号问题、创建 commit、push，并可能更新 PR body。

Reads prior outputs: `$ship` 之后的当前分支状态、PR、`CHANGELOG.md`、`VERSION`、各类 repo 级文档。

Execution flow:
1. 检测 base branch。
2. 对照 diff 和提交历史找出需要同步的文档。
3. 更新 README、ARCHITECTURE、CONTRIBUTING、CLAUDE、TODOS 等。
4. 只润色 `CHANGELOG`，不重写其事实内容。
5. 需要版本变化时显式询问。
6. commit 文档改动并 push。
7. 尽量把关键文档摘要同步进 PR body。

Produces / writes: 更新后的 repo 级文档、文档 commit、远端分支更新、可能更新的 PR body。

Success output: 文档层与当前 shipped branch 对齐。

Stops / failure modes: 在 base branch 上运行、文档同步需要版本决策但用户未确认、或 PR / gh 能力缺失。

Next recommended steps: `$land-and-deploy` 前后继续使用，或作为发布前最后一层文档收口。

## `$retro`（gstack）

Purpose: 对一段时间内的工程交付做复盘，而不是推动单个 task 向前。

Typical trigger: 一周或一个 sprint 结束后，想回看交付、代码质量和工作模式。

Inputs / source of truth: commit 历史、工作模式、代码质量信号。

Preconditions: 需要足够的历史数据；不要求 clean tree。

Git / branch state: 通常不要求特定分支；它更像读历史，不是写当前 feature。

Reads prior outputs: git 历史、团队或个人交付记录。

Execution flow:
1. 读取一段时间内的 commit 和工程信号。
2. 汇总做了什么、哪里顺、哪里卡。
3. 形成一份复盘报告。

Produces / writes: 复盘报告或对话输出。

Success output: 一份可用来指导下一轮流程优化的 retrospective。

Stops / failure modes: 历史数据不足，或用户只是要处理当前 task 而非做阶段复盘。

Next recommended steps: 根据复盘结果调整流程、task 拆分、测试策略或团队协作方式。

## 主链路依赖速查

### 常见先后顺序

- `memorize` 先于任何依赖 repo 导航准确性的工作
- `$office-hours` 常先于 `$autoplan` / `$plan-*`
- `$autoplan` 复用 `$plan-ceo-review`、`$plan-design-review`、`$plan-eng-review`
- `issue2task` 与 `gstack2task` 是互斥入口，且都直接产出可执行 task plan
- 半自动路径里，用户先审核 task plan，再交给 `autodev`
- `autodev` 常吸收 `simplify`、`checkpoint`、`design-review`、`review`、`qa`
- `automerge` 才进入 merge / 版本号 / 正式发布
- 手动路径里，`checktask` 常先于 `$ship`
- `$ship` 常先于 `$land-and-deploy`

### 半自动路径中被吸收或绕开的技能

- `autodev` 路径里，`checktask`、`$ship`、`$land-and-deploy` 不再是默认直接尾步
- `autodev` 默认消费 task 内已有的实现计划，而不是再依赖独立规划 skill
- `autodev` 会优先复用 `simplify`、`checkpoint`、`design-review`、`review`、`qa`
- `automerge` 会接管原本需要人工串起来的 `$ship` / `$land-and-deploy` / `$document-release` 收尾语义

### 手动路径中保留的显式门禁

- `$plan-ceo-review`
- `$plan-design-review`
- `$plan-eng-review`
- `$design-review`
- `$review`
- `$qa`
- `checktask`
- `$ship`
- `$land-and-deploy`
- `$document-release`
