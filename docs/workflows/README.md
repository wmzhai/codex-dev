# 总流程图

`docs/workflows/README.md` 是 codev + gstack 的唯一总流程图与总导航。默认先读这里，再跳到对应 skill 手册或旁支流程。

## 命名约定

- codev 自定义 skill 统一带 `codev-` 前缀，例如 `$codev-taskdev`、`$codev-quickship`。
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
│    └─► 先需求讨论确认，再产出 tasks/Txx-*.md + 对应 task 分支       │
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
│  默认主线：                                                         │
│  $codev-taskdev -> 人工验证 -> $codev-quickship                     │
│                                                                     │
│  验证门禁：                                                         │
│  有 UI 时 $design-review                                            │
│  结构审查 $review                                                   │
│  流程测试 $qa / $qa-only                                            │
└─────────────────────────────┬───────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────── 合并与发布收尾 ─────────────────────────┐
│  默认收尾路径：人工验证通过 -> $codev-quickship                     │
│                                                                     │
│  正式发布路径：$ship -> $land-and-deploy -> $document-release       │
│                 -> $canary                                          │
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
- `$codev-gstack2task` 仍然直接产出包含 `Implementation Plan` 与 `Validation Plan` 的 task 文件。
- `$codev-issue2task` 先基于代码和 issue 做需求讨论与确认，确认完关键细节后才落盘 task 文件。
- 审核 task plan 是强门禁；不接受就回 task 文件继续收敛。

### 4. task 分支执行

- 默认入口是 `$codev-taskdev`，负责 task 分支内的 plan 校准、编码、任务文档持续同步和一次实现收尾精简，不自动启动服务或执行验证。
- 功能验证默认由人工完成；`$codev-taskdev` 完成后，先人工验证，再决定是否进入 `$codev-quickship`。
- `$codev-simplify` 仍可单独使用；`$codev-checkpoint` 负责轻量提交 fallback，并默认同步版本工件；checkpoint 在未显式指定目标版本时默认把第 4 位加一。
- `$design-review`、`$review`、`$qa`、`$qa-only` 是验证门禁，不应该提前偷换成发布动作。

### 5. 合并与发布收尾

- 人工验证通过后，默认走 `$codev-quickship`：同步最终 task、归档到 `tasks/done/`、更新任务相关 `docs/` / `memory/` / 必要时 `AGENTS.md`，并同步根目录 `VERSION` 与 `CHANGELOG`；如果未显式指定目标版本，quickship 默认把最后一位加一，再完成 commit / merge / push；提交信息要使用 `type: 具体工作摘要 (vX.Y.Z.W)` 形式；如果 task 明确源自 GitHub issue，则在主干 push 成功后先补一条该轮工作的评论，再用 `gh` 关闭对应 issue。
- 需要 tag、正式发布或全局发布文档时，走 gstack `$ship -> $land-and-deploy -> $document-release`，再视需要补 `$canary`。
- `codev-quickship` 不创建 PR、不打 tag，也不接管正式发布。

## 旁支流程入口

- 浏览器与部署准备：见 [browser-and-deploy-prep.md](browser-and-deploy-prep.md)
- 安全、调试与专项审查：见 [safety-and-debug-branches.md](safety-and-debug-branches.md)

## 对应 skill 手册

- 总索引：见 [../skills/README.md](../skills/README.md)
- codev 自定义 skill：全部使用 `codev-*` 名称
- gstack skill：全部使用短调用名
