# Codev Skills

一组面向 Codex 的自定义 skills，用来整理需求、规划实现、验收任务、提交发版，以及对 diff 做语义不变的精简重构。

## 安装

仓库可以 clone 到任意目录，安装通过 `./setup` 完成：

```bash
git clone git@github.com:wmzhai/codev.git
cd codev
./setup
```

`./setup` 会把当前仓库安装到 `~/.codex/skills/`：

```text
~/.codex/skills/
├── codev -> /path/to/your/clone
├── issue2task -> codev/issue2task
├── plantask -> codev/plantask
├── checktask -> codev/checktask
├── simplify -> codev/simplify
└── ships -> codev/ships
```

## 调用方式

Codex skills 支持两种常见使用方式：

1. 显式调用：直接在提示里写 `$skill-name`
2. 语义触发：描述足够明确时，系统可能自动选择合适 skill

推荐优先使用显式调用，尤其是有副作用或目标很明确的 skill。

示例：

```text
$issue2task 42
$plantask T05
$checktask
$ships
$ships v1.2.3
$simplify
```

## 典型工作流

1. 在 GitHub 上创建或整理 issue。
2. 用 `$issue2task` 分析 issue、阅读相关代码、澄清需求，并生成 `tasks/` 下的任务文件。
3. 用 `$plantask` 读取待办任务，结合代码现状产出详细实现方案，并在结尾主动询问用户是接受后进入实现，还是继续讨论。
4. 用户接受方案后，直接按方案实现并迭代；如果用户有疑问或想改范围，则继续讨论后再定。
5. 用 `$checktask` 逐项核对验收标准，更新 checklist；如果用户在执行过程中改动了实现，导致 task 文档与实际结果漂移，则以已验证的实际结果为准同步任务文档，并在流程末尾自动对本次相关 diff 做一次语义不变的精简，再按最新已验证内容更新 `memory/` 与 `docs/`；全部通过后归档到 `tasks/done/`。
6. 需要提交时用 `$ships` 提交并推送。
7. 没有 task，或需要单独精简某次 patch 时，用 `$simplify` 对 diff 做语义不变的重构。
8. 需要发版时，用 `$ships vX.Y.Z` 或 `$ships vX.Y.Z-rcN`。

## 项目文档约定

所有基于这组 skill 的项目，默认都应具备三类文档目录：

- `tasks/`：管理工作任务。这部分已经由 `issue2task`、`plantask`、`checktask` 这套流程直接消费和维护。
- `memory/`：管理面向 Codex 的检索型项目记忆，并与根目录的 `AGENTS.md` 一起构成项目记忆系统。`AGENTS.md` 负责高优先级规则、默认工作方式和最短入口；`memory/` 负责按主题组织长期知识、约束、排查路径和模块落点。Codex 了解项目，主要依赖这套记忆系统和具体代码，而不是依赖面向人类的说明文档。
- `docs/`：管理给人类阅读的说明文档，例如背景介绍、设计说明、使用手册、对外文档等。正常情况下 agent 不需要把它作为默认阅读入口。

`AGENTS.md` 和 `memory/` 的配合方式建议如下：

- 阅读顺序上，默认先看 `AGENTS.md`，再按问题进入 `memory/`。前者用于快速建立当前仓库的工作边界，后者用于按主题继续检索。
- 内容分工上，`AGENTS.md` 只放高优先级、跨目录共享、几乎每次开始工作都需要先知道的规则和事实；`memory/` 则承接更细的模块知识、约束说明、排查路径、运行流程和目录落点。
- 写作目标上，`AGENTS.md` 追求短、硬、稳定，像“项目操作系统”；`memory/` 追求可检索、可扩展，像“项目知识索引”。
- 维护原则上，尽量不要在两处重复堆文案：能放在 `AGENTS.md` 的，应当是全局规则；需要按主题展开、未来会持续补充的，再放进 `memory/`。
- 使用方式上，Codex 应优先依赖 `AGENTS.md`、`memory/` 和实际代码理解项目；`docs/` 主要服务人类沟通，不承担默认机器记忆入口的职责。

推荐结构：

```text
project/
├── AGENTS.md
├── tasks/
├── memory/
└── docs/
```

## Skills 一览

| Skill | 调用 | 说明 |
|------|------|------|
| `issue2task` | `$issue2task` | 从 GitHub issues 生成带依赖关系的任务文件 |
| `plantask` | `$plantask` | 基于任务文件和代码现状输出实现方案，并在结尾收口到“开始实现/继续讨论” |
| `checktask` | `$checktask` | 验收任务、更新 checklist、同步相关文档、归档已完成任务 |
| `ships` | `$ships` | 提交并推送当前分支，可选创建 release tag |
| `simplify` | `$simplify` | 供 `checktask` 内部复用，或在无 task 时单独精简给定 diff |

## Skill 说明

### issue2task

读取一个或多个 GitHub issue，结合代码现状先自行收敛需求，再生成 `tasks/Txx-*.md`。

常见用法：

```text
$issue2task 42
$issue2task #42
$issue2task --label backend
```

产出通常包括：

- `tasks/Txx-*.md`

这个 skill 关注需求整理和任务拆分，不负责实现方案设计。`tasks/` 里不需要额外索引，任务文件名本身就是索引。默认会直接写出可交接的任务文件，只有阻塞性歧义才会中途提问。

### plantask

读取 `tasks/` 中的待办任务，检查依赖是否完成，深入相关代码，输出可直接实施的计划。

常见用法：

```text
$plantask
$plantask T05
```

这个 skill 本轮只做规划，不会直接改代码。默认应一次性给出可执行方案，并在结尾主动问用户是接受后开始实现，还是继续讨论；用户接受后，下一轮直接进入实现，不需要重新把改动要求再说一遍。

### checktask

逐项核对任务文件中的验收标准，更新通过项的 checkbox；如果执行过程中实现已经变化，以已验证的实际结果同步任务文档；在流程末尾最多自动对本次相关 diff 做一次语义不变的精简，并按最新已验证内容更新 `memory/` 与 `docs/`；全部通过时归档到 `tasks/done/`。

常见用法：

```text
$checktask
$checktask T04
```

它会优先做最小侵入验证，只在标准明确要求时运行测试或命令。遇到模糊标准时，应标记为需要人工确认，而不是猜测通过。如果用户在验收过程中修改了实现，导致 task 文案过期，应以已验证的实际结果为准回写相关任务内容，而不是强行要求实现继续贴合旧文案。验收步骤结束后，会在整个流程末尾最多自动调用一次 `simplify` 风格的本地精简，并顺带对与本任务直接相关的 `memory/` 和 `docs/` 做基于已验证事实的同步更新；这里的更新可以是新增、修改，也可以是删除过期内容，但不应扩大成无关的文档整理。

### ships

提交当前工作区并推送当前分支；如果提供版本号，再创建并推送 tag。

常见用法：

```text
$ships
$ships v0.1.3
$ships v1.0.0-rc1
```

`ships` 是显式调用优先的 skill。当前配置下不会默认隐式触发。

### simplify

针对给定 diff 做语义不变的精简重构，目标是降低嵌套、去重、改进局部命名、使用更惯用的写法，但不改变行为、不引入依赖、不改 API。它主要作为 `checktask` 的内部步骤存在；没有 task 时也可以单独使用。默认直接落地最小修改，并只返回简短摘要，不打印完整 patch 或大段源码。

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
my-skill/
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
