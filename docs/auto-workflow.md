# 自动流程

这份文档只讲一件事：当仓库同时接入 `codev` 和 `gstack` 时，如何把 `autoplan + autodev + automerge` 串成一条更安全、更省人工的半自动开发路径。

它不展开每个 skill 的完整内部实现。需要看 skill 级细节、产物路径、clean tree 要求、提交状态要求时，直接跳到 [Skill 详细手册](skill-reference.md)。

## 这条路径解决什么问题

当上游规划已经可以被结构化、下游开发流程又相对固定时，逐个手动运行 review、QA、deploy、merge 很容易重复劳动。半自动路径的目标是：

- 上游规划仍然保持高质量，不跳过 CEO / Design / Eng review。
- task 分支内的实现、验证、分支部署尽可能自动完成。
- 最终 merge 和版本号仍然保留给人类确认之后再发生。

这条路径的核心不是“全自动到底”，而是“把自动化停在最安全的位置”。

## 何时适合用

- 仓库已经同时使用 `codev` 和 `gstack`。
- 你希望大部分下游步骤自动推进，只在高价值节点介入。
- 仓库支持 preview、staging、branch deploy 或等价的非主干验证环境。
- task 的执行边界已经比较清楚，不需要每一步都重新谈 scope。

## 何时不要用

- 仓库只能通过 merge `main/master` 触发部署。
- 你希望每个规划和验证步骤都由人类逐项审核、逐项确认。
- 当前任务有大量开放性产品决策，`autodev` 很可能频繁撞到硬阻塞。
- 你要同时推进多个相互缠绕的 task，而不是一个 task 一条分支。

## 高层链路

```text
$office-hours
-> $autoplan
-> $gstack2task 或 $issue2task
-> 审核 task plan
-> $autodev
-> 人工确认部署结果
-> $automerge
```

如果需求已经明确、设计文档已经存在，可以跳过 `$office-hours`。如果任务来源不是 gstack 工件，而是 GitHub issue 或直接需求，则走 `$issue2task`。

## 阶段总览

| 阶段 | 主导者 | 主要输入 | 主要输出 |
|------|--------|---------|---------|
| 上游规划 | gstack | 需求、问题定义、已有设计上下文 | 设计文档、review 过的 plan、测试计划 |
| 任务生成 | codev | gstack 工件或 issue / 直接需求 | `tasks/T{nn}-{slug}.md` + task 分支 + executable plan |
| plan 审核 | 人类 | task 文件中的 `Implementation Plan` / `Validation Plan` | 明确接受 plan 或退回重写 |
| 分支内自动闭环 | codev | 已审核的 task 文件、代码、已有规划结果 | 基于 task plan 的已部署待人工确认 task 分支 |
| 人工确认 | 人类 | 最新部署结果 + task 文档 | 明确确认或退回修改 |
| 正式收尾 | codev / gstack | 已确认的 task 分支 | merge、版本号、正式发布、任务归档 |

## 阶段 1：上游规划

### 1.1 `$office-hours`

当问题还没有被压成一个足够好的 feature design 时，先用 `$office-hours`。它的任务不是写 task，而是逼出：

- 问题定义
- 假设与前提
- 备选方案
- 推荐方向

这一阶段的主产物在 `~/.gstack/projects/{slug}/` 下，是后面 review 和 task 生成的上游 source of truth。

### 1.2 `$autoplan`

`$autoplan` 是上游 review 的自动串联器。它顺序调用 CEO、Design、Eng review，把中间能自动决策的部分直接处理掉，只在高价值判断上停下来。

在半自动路径里，它的作用不是替代人工思考，而是把：

- CEO 级 scope / ambition 审查
- 设计完整度审查
- 工程架构与测试计划审查

压成一次更顺滑的 review 管道。

如果用户在这里做了品味判断、scope 取舍或方案选择，这些决定应该在后续 task 生成前就稳定下来。

## 阶段 2：生成 task

这一步把上游意图落成 repo 内执行单元。

- 如果输入来自 `~/.gstack/projects/`，用 `$gstack2task`
- 如果输入来自 GitHub issue 或直接需求，用 `$issue2task`

这一步的结果不是代码，而是：

- 一个或多个 `tasks/T{nn}-{slug}.md`
- 每个 task 自己的分支
- 每个 task 自带的实现计划和验证计划

半自动路径默认仍是一 task 一分支。`autodev` 一次只闭环一个 task，不批量扫完整个待办列表。

## 阶段 3：先审核 task plan

这里的人类职责很明确：

- 确认 task 边界没有漂移
- 确认 `Implementation Plan` 的默认路径就是你要的方案
- 确认 `Validation Plan` 足以覆盖关键风险

如果 plan 不成立，应该先回到 task 文件收敛，而不是让 `autodev` 带着错误前提直接开工。

如果你只想执行编码、不想自动跑完整个闭环，应切回人工路径并使用 `$taskdev`；半自动路径本身不需要额外先跑 `$taskdev`。

## 阶段 4：`$autodev` 在 task 分支上自动闭环

这是半自动路径的核心阶段。

`$autodev` 接手之后，会在 task 分支内自动推进：

- 内含 `$taskdev` 的任务选择、plan 校准和编码阶段
- 先读取 task 中已有的 `Implementation Plan` / `Validation Plan`
- 必要时按代码现状小幅校准 task plan
- 读取并补齐 task 文档
- 规划与实现
- `simplify`
- 中间稳定提交或 `checkpoint`
- 设计审查、结构审查、测试、浏览器验证
- 分支部署
- 部署后验证

### 这一阶段最重要的约束

1. `autodev` 默认全程中文交流。
2. 它会持续更新对应的 `tasks/T{nn}-{slug}.md`，而不是只在最后打勾。
3. 它的起点是“已经写好并被用户审核过的 task plan”，不是从零再做一轮独立规划；也不需要先显式调用 `$taskdev`。
4. 它停在“已部署待人工确认”。
5. 它不 merge 主干，不打版本号，不归档任务。

### `autodev` 结束时应该看到什么

- task 分支上已有完整实现
- 必要的验证已经跑完
- 分支已经部署到可验证环境
- task 文档已经记录：
  - 实际采用的实现路径
  - 关键执行步骤
  - 重要验证结果
  - 部署信息
  - 剩余风险和待确认项

### `autodev` 为什么不直接 merge

因为半自动路径把“看见最终结果”放在 merge 之前。

更安全的顺序是：

1. 先在 task 分支上做完实现和部署
2. 让用户在真实部署结果上确认
3. 再进入主干合并和版本号

这样能避免“为了看看效果先 merge 一次”的高风险习惯。

## 阶段 5：人工确认

这一步是半自动路径里最重要的人类职责。

用户此时不是重新 review 每个 commit，而是确认：

- 部署出来的功能是否真的满足目标
- 用户可见交互是否达到预期
- 还有没有必须在 merge 前处理的风险

如果确认不通过，通常有两种做法：

- 继续在当前 task 分支修正，然后再跑一次 `$autodev`
- 或切回人工路径，手动修正和验证

## 阶段 6：`$automerge` 正式收尾

只有在用户明确确认后，才进入 `$automerge`。

它的职责和 `autodev` 刻意分开：

- merge 到 `main/master`
- 处理版本号
- 走正式发布路径
- 归档任务到 `tasks/done/`

如果仓库原本已经依赖 gstack 的 `$ship`、`$land-and-deploy`、`$document-release`，`automerge` 可以复用这些能力；但用户只需要记住一点：

`autodev` 负责“在分支上做到可确认”，`automerge` 负责“确认后收口到主干”。

## 这条路径里的人工停点

半自动不等于无人值守。默认的人类停点只有几类：

- `$autoplan` 遇到真正需要人拍板的 taste / scope 决策
- 用户审核 task plan
- `$autodev` 遇到硬阻塞：
  - 缺权限
  - 缺凭证
  - 缺分支部署能力
  - 出现无法安全默认选择的高影响修复路径
- 用户确认部署结果
- `$automerge` 前的最终放行

除此之外，不应该把每个小问题都重新抛回给人类。

## 这条路径里的 source of truth

- 上游产品与规划事实：`~/.gstack/projects/{slug}/`
- repo 内执行单元：`tasks/T{nn}-{slug}.md`
- 分支内最新实现与验证状态：当前 task 分支
- merge 前最终确认：用户对部署结果的明确确认

## 推荐读法

- 想知道整条半自动路径怎么串：继续读这份文档即可。
- 想知道手动路径怎么跑：看 [工作流程](workflow.md)。
- 想知道每个 skill 的内部流程、产物和前置状态：看 [Skill 详细手册](skill-reference.md)。
