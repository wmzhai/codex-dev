# 总流程图

`docs/workflows/README.md` 是 codev + gstack 的唯一总流程图与总导航。默认先读这里，再跳到对应 skill 手册或旁支流程。

## 命名约定

- codev 自定义 skill 统一带 `codev-` 前缀，例如 `$codev-taskdev`、`$codev-autodev`。
- gstack 安装目录使用 `gstack-*` 包名，但调用仍然使用 `$office-hours`、`$qa`、`$ship` 这类短名。

## 从开始到结束的完整流程

```text
┌──────────────────────────── 仓库级准备 ─────────────────────────────┐
│  README.md -> docs/workflows/README.md -> docs/skills/*.md         │
│                                                                     │
│  $codev-memorize                                                    │
│    └─► AGENTS.md + memory/ + 文档导航                               │
│                                                                     │
│  可选旁支：                                                         │
│  $careful / $freeze / $guard / $unfreeze                            │
│  $gstack / $browse / $setup-browser-cookies / $setup-deploy         │
│  $investigate / $benchmark / $cso                                   │
└─────────────────────────────┬───────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────── 上游规划 ───────────────────────────────┐
│  $office-hours                                                      │
│    └─► ~/.gstack/projects/{slug}/*-design-*.md                      │
│                                                                     │
│  $plan-ceo-review / $plan-design-review / $plan-eng-review          │
│  或 $autoplan                                                       │
│    └─► design doc + review 结果 + test plan                         │
│                                                                     │
│  有 UI 且缺设计系统时：$design-consultation -> DESIGN.md            │
└─────────────────────────────┬───────────────────────────────────────┘
                              │
                              ▼
┌────────────────────────── 任务生成与审核 ───────────────────────────┐
│  gstack 工件 -> $codev-gstack2task                                  │
│  issue / 直接需求 -> $codev-issue2task                              │
│    └─► tasks/Txx-*.md + 对应 task 分支                              │
│                                                                     │
│  人工审核 task plan                                                 │
│    └─► 确认 Implementation Plan / Validation Plan                   │
│                                                                     │
│  scope 漂移或风险过高时，可补跑：                                   │
│  $plan-eng-review / $plan-design-review / $autoplan                │
└─────────────────────────────┬───────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────── task 分支执行 ──────────────────────────┐
│  手动主线：                                                         │
│  $codev-taskdev -> $codev-simplify -> commit / $codev-checkpoint    │
│                                                                     │
│  自动旁支：                                                         │
│  $codev-autodev                                                     │
│    └─► 内含 $codev-taskdev + 审查 + 测试 + 分支部署                 │
│    └─► 停在“已部署待人工确认”                                        │
│                                                                     │
│  验证门禁：                                                         │
│  有 UI 时 $design-review                                            │
│  结构审查 $review                                                   │
│  流程测试 $qa / $qa-only                                            │
│                                                                     │
│  验收：$codev-checktask                                             │
└─────────────────────────────┬───────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────── 合并与发布收尾 ─────────────────────────┐
│  轻量路径：确认当前结果可直推 -> $codev-quickship                   │
│                                                                     │
│  人工路径：$ship -> $land-and-deploy -> $document-release -> $canary│
│                                                                     │
│  自动正式路径：人工确认 -> $codev-automerge                         │
│    └─► 如兼容则复用 $ship / $land-and-deploy / $document-release   │
│                                                                     │
│  可选复盘：$retro                                                   │
└─────────────────────────────────────────────────────────────────────┘
```

## 阶段解释

### 1. 仓库级准备

- 默认先读 `README.md`、本文和 `docs/skills/README.md`。
- `$codev-memorize` 只负责收敛 repo 事实、`AGENTS.md`、`memory/` 与文档导航。
- 安全工具、浏览器准备、调试/专项审查都属于这里可以插入的条件性旁支，不是默认每次都跑。

### 2. 上游规划

- gstack 负责产品探索、scope/设计/工程评审与测试计划。
- `~/.gstack/projects/` 是这里的 source of truth。
- 如果还没有稳定 design doc，不要直接跳到 task。

### 3. 任务生成与审核

- codev 只有两个任务入口：`$codev-issue2task` 和 `$codev-gstack2task`。
- 两者都必须直接产出包含 `Implementation Plan` 与 `Validation Plan` 的 task 文件。
- 审核 task plan 是强门禁；不接受就回 task 文件继续收敛。

### 4. task 分支执行

- 手动主线默认入口是 `$codev-taskdev`。
- `$codev-simplify` 和 `$codev-checkpoint` 只负责收窄 patch 与轻量提交。
- `$codev-autodev` 是旁支自动闭环：它内含 `$codev-taskdev` 阶段，但不会 merge 主干。
- `$design-review`、`$review`、`$qa`、`$qa-only` 是验证门禁，不应该提前偷换成发布动作。

### 5. 合并与发布收尾

- 小改动且允许直接推主干时，可走 `$codev-quickship`：在分支上就 merge 到主干，在主干上就直接 commit + push。
- 人工路径默认是 `$ship -> $land-and-deploy`，再视需要补 `$document-release` 与 `$canary`。
- 自动正式路径必须先人工确认，再运行 `$codev-automerge`。
- `codev-quickship` 不处理版本号和正式发布；`$codev-automerge` 才负责 codev 自动链路中的正式发布收尾。

## 旁支流程入口

- 自动闭环：见 [auto-dev-loop.md](auto-dev-loop.md)
- 浏览器与部署准备：见 [browser-and-deploy-prep.md](browser-and-deploy-prep.md)
- 安全、调试与专项审查：见 [safety-and-debug-branches.md](safety-and-debug-branches.md)

## 对应 skill 手册

- 总索引：见 [../skills/README.md](../skills/README.md)
- codev 自定义 skill：全部使用 `codev-*` 名称
- gstack skill：全部使用短调用名
