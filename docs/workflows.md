# 工作流总览

`docs/workflows.md` 是 codev 的唯一工作流导航。默认先读这里，再按需要进入对应的 skill 手册。

文档里的 `$codev-*` 是 Codex 写法；Grok 把 `$` 换成 `/`，例如 `/codev-taskdev`。

## 默认主线

```text
README.md
-> docs/workflows.md
-> docs/skills/README.md
-> 选择任务入口
   - issue / 直接需求 -> $codev-issue2task
-> 人工审核 task plan
-> $codev-taskdev
-> 人工验证
-> $codev-quickship

同步开源上游且保留本地补丁：$codev-syncpatch
轻量提交 fallback：$codev-checkpoint
```

## 主流程说明

### 1. 仓库准备

- 默认先读 `README.md`、本文和 `docs/skills/README.md`。
- 需要刷新仓库记忆入口时，用 `$codev-memorize`。
- `setup` 只安装本仓库当前受管的 codev skills，并同时刷新 Codex（`~/.codex/skills`）和 Grok（`~/.grok/skills`）。

### 2. 任务入口

- GitHub issue 或直接需求，都走 `$codev-issue2task`。
- 任务入口统一落成 `tasks/` 下可执行的 task 文件。

### 3. task 审核与实现

- 先人工审核 task 文件里的 `Implementation Plan` / `Validation Plan`。
- 审核通过后，用 `$codev-taskdev` 在 task 分支推进实现。
- `codev-taskdev` 负责代码实现、任务文档同步，以及一次实现收尾精简和默认 build / 最小编译校验。

### 4. 验证与收尾

- 功能验证默认由人工完成。
- 人工确认通过后，用 `$codev-quickship` 做 task 归档、相关文档同步和主干收尾；用户触发 quickship/checkpoint 即表示 `codev-taskdev` 收尾校验和人工验证已经完成，收口阶段不再运行 build/test/lint/typecheck 或脚本验证。
- 如果仓库没有 task，也可按无 task 模式收尾，但要在 `CHANGELOG` 记录本轮改动摘要。
- 无 task 模式同样依赖用户触发前已完成外部确认，不由 `$codev-quickship` 或 `$codev-checkpoint` 承担自动验证。
- 只想做一次轻量 `commit / push` 时，用 `$codev-checkpoint`；checkpoint 默认同步已有 `CHANGELOG` 的未发布记录，不升级 `VERSION`、不创建或推送 tag。

### 5. 开源上游同步与本地补丁

- 长期跟踪开源项目、但需要保留本地运行补丁时，用 `$codev-syncpatch`。
- syncpatch 默认不提交、不 push、不默认创建分支。
- 它必须先分析本地补丁意图和 upstream 改动风险；如果不能高置信度补回本地逻辑，会先停下和用户确认，而不是继续高风险合并。

## 相关文档

- skill 索引：`docs/skills/README.md`
- 仓库级事实与维护规则：`AGENTS.md`
