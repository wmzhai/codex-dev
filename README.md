# Codex Skills

一组面向 Codex 的自定义 skills，用来整理需求、规划实现、验收任务、提交发版，以及对 diff 做语义不变的精简重构。

## 安装

将这些 skill 放在 `~/.codex/skills/` 目录下即可被当前环境识别：

```bash
git clone <repo> ~/.codex/skills
```

如果目录里已经有其他 skill，按需合并即可。每个 skill 至少包含一个 `SKILL.md`，可选包含 `agents/openai.yaml`。

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
$ship
$ship v1.2.3
$simplify
```

## 典型工作流

1. 在 GitHub 上创建或整理 issue。
2. 用 `$issue2task` 分析 issue、阅读相关代码、澄清需求，并生成 `tasks/` 下的任务文件。
3. 用 `$plantask` 读取待办任务，结合代码现状产出详细实现方案。
4. 按方案实现并迭代。
5. 用 `$checktask` 逐项核对验收标准，更新 checklist，并在流程末尾自动对本次相关 diff 做一次语义不变的精简；全部通过后归档到 `tasks/done/`。
6. 需要提交时用 `$ship` 提交并推送。
7. 没有 task，或需要单独精简某次 patch 时，用 `$simplify` 对 diff 做语义不变的重构。
8. 需要发版时，用 `$ship vX.Y.Z` 或 `$ship vX.Y.Z-rcN`。

## Skills 一览

| Skill | 调用 | 说明 |
|------|------|------|
| `issue2task` | `$issue2task` | 从 GitHub issues 生成带依赖关系的任务文件 |
| `plantask` | `$plantask` | 基于任务文件和代码现状输出实现方案 |
| `checktask` | `$checktask` | 验收任务、更新 checklist、归档已完成任务 |
| `ship` | `$ship` | 提交并推送当前分支，可选创建 release tag |
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
- `tasks/README.md`

这个 skill 关注需求整理和任务拆分，不负责实现方案设计。默认会直接写出可交接的任务文件，只有阻塞性歧义才会中途提问。

### plantask

读取 `tasks/` 中的待办任务，检查依赖是否完成，深入相关代码，输出可直接实施的计划。

常见用法：

```text
$plantask
$plantask T05
```

这个 skill 只做规划，不会改代码。默认应一次性给出可执行方案，而不是把“等你确认实现方向”当成常规中间步骤。

### checktask

逐项核对任务文件中的验收标准，更新通过项的 checkbox；在流程末尾最多自动对本次相关 diff 做一次语义不变的精简；全部通过时归档到 `tasks/done/`。

常见用法：

```text
$checktask
$checktask T04
```

它会优先做最小侵入验证，只在标准明确要求时运行测试或命令。遇到模糊标准时，应标记为需要人工确认，而不是猜测通过。验收步骤结束后，会在整个流程末尾最多自动调用一次 `simplify` 风格的本地精简，而不是重复调用或只给出建议。

### ship

提交当前工作区并推送当前分支；如果提供版本号，再创建并推送 tag。

常见用法：

```text
$ship
$ship v0.1.3
$ship v1.0.0-rc1
```

`ship` 是显式调用优先的 skill。当前配置下不会默认隐式触发。

### simplify

针对给定 diff 做语义不变的精简重构，目标是降低嵌套、去重、改进局部命名、使用更惯用的写法，但不改变行为、不引入依赖、不改 API。它主要作为 `checktask` 的内部步骤存在；没有 task 时也可以单独使用。

常见用法：

```text
$simplify

<paste diff here>
```

如果没有直接给 diff，也可以让它基于当前 patch 进行精简。`checktask` 内部调用时，应直接复用已经确定的相关最小 diff，并且整个 `checktask` 流程里只调用一次；单独使用时，`simplify` 仍然是显式调用优先。

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
  display_name: "My Skill"
  short_description: "Short description"
  default_prompt: "Use $my-skill to ..."

policy:
  allow_implicit_invocation: false
```

说明：

- `name` 和目录名应保持一致。
- frontmatter 只需要 `name` 和 `description`。
- `description` 既要描述能力，也要描述“什么时候使用它”。
- `allow_implicit_invocation: false` 表示这个 skill 只适合显式调用。
