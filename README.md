# Codev Skills

`codev` 是一组给 Codex 用的开发流程 skills，负责把需求收敛成 repo 内任务，并管理实现过程里的细节：

- 需求或上游工件转 `tasks/`
- 任务实施前规划
- 任务验收与归档
- `AGENTS.md` 与 `memory/` 维护
- 轻量 checkpoint 提交

它可以单独使用，也可以和 `gstack` 配合。

## 适合什么场景

- 你只用 Codex，不用 Claude
- 你想把开发过程落到 repo 内的 `tasks/`、`memory/`、`AGENTS.md`
- 你希望 `gstack` 负责上游 planning / review / qa / ship，`codev` 负责 repo 内任务流

## 安装

### 安装 codev

```bash
git clone git@github.com:wmzhai/codev.git
cd codev
./setup
```

安装后会把这些 skills 链接到 `~/.codex/skills/`：

```text
memorize
issue2task
gstack2task
plantask
checktask
simplify
checkpoint
```

### 可选：安装 gstack

如果你还想用 `$office-hours`、`$plan-ceo-review`、`$plan-design-review`、`$plan-eng-review`、`$review`、`$qa`、`$ship` 这些上游/发布流程，再装 `gstack`：

```bash
git clone https://github.com/garrytan/gstack.git ~/gstack
cd ~/gstack
./setup --host codex
```

如果你想把 `gstack` 跟项目一起放进仓库，也可以放到 repo 内的 `.agents/skills/gstack/` 后再运行：

```bash
cd /path/to/your/project
git clone https://github.com/garrytan/gstack.git .agents/skills/gstack
cd .agents/skills/gstack
./setup --host codex
```

说明：

- 这里统一使用 Codex 风格命令：`$review`、`$qa`、`$ship`
- 不再使用 Claude 风格的 `/review`、`/qa`、`/ship`

## 最短上手

### 纯 codev

适合老项目，需求已经明确，不需要完整的 planning / QA / PR gate。

```text
$memorize
→ $issue2task
→ $plantask
→ 实现 + 项目自己的测试
→ $checktask
→ $checkpoint
```

### codev + gstack

适合新功能、需要上游规划、设计审查、结构 review、浏览器 QA 和正式 ship。

```text
main/master
→ $memorize
→ $office-hours
→ $plan-ceo-review
→ （有 UI 且还没有 DESIGN.md 时）$design-consultation
→ （有 UI 时）$plan-design-review
→ $plan-eng-review
→ $gstack2task 或 $issue2task   （这里开始切到某个 task 自己的分支）
→ $plantask                     （后续都在这个 task 分支上）
→ 实现
→ 普通 commit 或 $checkpoint   （先把当前实现收成 clean tree）
→ （有 UI 时）$design-review
→ $review
→ （若 $review 改了代码，先验证并补一次普通 commit 或 $checkpoint）
→ $qa
→ $checktask
→ $ship
→ PR merge 回 main
→ 切回 main，同步主线
```

## 两套系统怎么分工

### codev 负责

- `$issue2task`：GitHub issue 或直接需求转 task
- `$gstack2task`：把 `~/.gstack/projects/` 下的 gstack 工件转 task
- `$plantask`：把 task 压成可执行实施方案
- `$checktask`：按验收标准收口、归档、同步 `memory/`
- `$memorize`：维护 `AGENTS.md` 和 `memory/`
- `$checkpoint`：轻量 `commit + push`

### gstack 负责

- `$office-hours`：问题定义 / design doc
- `$plan-ceo-review`：产品和 scope 收敛
- `$design-consultation`：生成 `DESIGN.md`
- `$plan-design-review`：实现前设计审查
- `$plan-eng-review`：工程方案和 test plan
- `$review`：结构性 code review
- `$design-review`：实现后的视觉 QA
- `$qa` / `$qa-only`：浏览器 QA
- `$ship`：测试、PR、发布收口
- `$document-release`：repo 级文档同步

## 最重要的规则

### 任务入口分开

- GitHub issue 或直接需求：用 `$issue2task`
- `~/.gstack/projects/` 下的 design doc / handoff / test plan：用 `$gstack2task`
- 两者不要混成一个入口

### 每个步骤在哪个分支上做

- `$memorize`、`$office-hours`、`$plan-ceo-review`、`$design-consultation`、`$plan-design-review`、`$plan-eng-review`
  - 通常从 `main` 或 `master` 开始即可；这些步骤主要产出规划工件，不是 repo 内实现分支
- `$issue2task`、`$gstack2task`
  - 在当前 `HEAD` 上为每个 task 新建并切到该 task 自己的分支
- `$plantask`
  - 应在目标 task 自己的分支上运行
  - 如果你还停在 `main/master`，它会先切过去再继续
- 实现、普通 commit、`$checkpoint`、`$design-review`、`$review`、`$qa`、`$checktask`、`$ship`
  - 都在当前 task 自己的分支上完成
- `main/master`
  - 只作为 planning 起点和最终 merge 终点
  - 不要在 `main/master` 上直接做实现、`$design-review`、`$qa`、`$ship`

### 任务号和分支

- 任务号只用纯数字：`T01`、`T02`、`T03`
- 不再使用 `T18a`、`T18b` 这种后缀
- 每个 task 一条独立分支
- 多个 task 不能共享同一条分支

### 什么时候切分支

- 默认在 `$issue2task` 或 `$gstack2task` 时切分支
- 这两个 skill 会在写入 task 文件前，先切到该 task 自己的分支
- 如果你在 `main` 或 `master` 上执行 `$plantask`，它会先切到目标 task 对应的分支再继续

### 什么时候需要 `$checkpoint`

- 在第一次实现完成、准备跑 `$design-review` 或 `$qa` 前，先做一次普通 commit 或 `$checkpoint`
- 因为 `$design-review` 和 `$qa` 都要求 clean working tree
- 如果 `$review` 改了代码，而你后面还要继续 `$qa`、`$checktask`、`$ship`，也先补一次普通 commit 或 `$checkpoint`
- 如果你只是想把当前 task 分支临时推到远端，也可以直接用 `$checkpoint`

### 什么时候合并回 main

- `codev` 不负责自动合并回 `main`
- 正常顺序是：task 分支完成实现和验收后，再通过你自己的 PR / merge 流程合回 `main`
- 合并完成后，切回 `main`，同步主线，再开始下一轮 task

### `$checktask` 不是第一次提交代码的时机

`$checktask` 是验收和归档，不是第一次提交代码。

更合理的顺序是：

```text
task 分支上实现
→ 普通 commit 或 $checkpoint
→ $design-review / $review / $qa
→ 如果中间又产生新修改，继续补普通 commit 或 $checkpoint
→ $checktask
→ $ship
```

### `$design-review` 和 `$qa` 的前提

- 这两个 skill 都要求 clean working tree
- 它们会自己产生原子 fix commits
- 所以在跑它们之前，先把手头改动提交掉或 stash 掉

### `$review` 的前提

- `$review` 会基于当前 diff 做结构审查
- 它可能 auto-fix，但默认不会替你自动创建 commit
- 如果它改了代码，先自己验证，再补一次普通 commit 或 `$checkpoint`，然后再继续 `$qa`、`$checktask` 或 `$ship`

## 常见流程

### 1. 需求已经在 GitHub issue 里

```text
main/master
→ $memorize
→ $issue2task 42          （切到该 task 分支）
→ $plantask Txx
→ 实现
→ $checkpoint
→ $review
→ （若 $review 改了代码，补一次普通 commit 或 $checkpoint）
→ $qa
→ $checktask
→ $ship
→ PR merge 回 main
```

### 2. 已经先用 gstack 做过 planning

```text
main/master
→ $office-hours
→ $plan-ceo-review
→ $plan-eng-review
→ $gstack2task            （切到该 task 分支）
→ $plantask
→ 实现
→ $checkpoint
→ $review
→ （若 $review 改了代码，补一次普通 commit 或 $checkpoint）
→ $qa
→ $checktask
→ $ship
→ PR merge 回 main
```

### 3. 老项目，只想要轻量任务流

```text
main/master
→ $issue2task 修复结算页空购物车 500   （切到该 task 分支）
→ $plantask
→ 实现
→ $checkpoint
→ $checktask
→ 需要推远端时再 $checkpoint
```

## 常用命令

```text
$memorize
$issue2task
$issue2task 42
$issue2task 修复结算页空购物车时的 500
$gstack2task
$gstack2task ~/.gstack/projects/my-project/xxx-implementation-plan-20260322-105643.md
$plantask
$plantask T05
$checktask
$checkpoint
```

## Skills 速查

| Skill | 用途 |
|------|------|
| `$memorize` | 刷新 `AGENTS.md` 和 `memory/` |
| `$issue2task` | 从 issue 或直接需求生成 `tasks/` |
| `$gstack2task` | 从 gstack 工件生成 `tasks/` |
| `$plantask` | 输出某个 task 的实施方案 |
| `$checktask` | 验收 task、更新 checklist、归档到 `tasks/done/` |
| `$checkpoint` | 轻量 `commit + push` |
| `$simplify` | 语义不变精简 diff |

## 下游项目建议目录

```text
project/
├── AGENTS.md
├── tasks/
├── memory/
├── docs/
└── README.md
```

说明：

- `AGENTS.md` + `memory/` 给 Codex 用
- `tasks/` 给 `issue2task` / `gstack2task` / `plantask` / `checktask` 用
- `docs/` 主要给人看，不是默认机器入口

## 测试安装脚本

```bash
./test/setup-smoke.sh
```

## 维护这个仓库时

- 新增或修改 skill，优先同步 `SKILL.md`
- 然后同步 `agents/openai.yaml`
- 再检查 `setup`、`test/setup-smoke.sh`、`README.md`
- `issue2task` 和 `gstack2task` 的输入边界不要揉在一起
