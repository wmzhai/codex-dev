# 工作流总览

`docs/workflows.md` 是 codev 的唯一工作流导航。默认先读这里，再按需要进入对应的 skill 手册。

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

轻量提交 fallback：$codev-checkpoint
```

## 主流程说明

### 1. 仓库准备

- 默认先读 `README.md`、本文和 `docs/skills/README.md`。
- 需要刷新仓库记忆入口时，用 `$codev-memorize`。
- `setup` 只安装本仓库当前受管的 codev skills。

### 2. 任务入口

- GitHub issue 或直接需求：`$codev-issue2task`

任务入口统一落成 `tasks/` 下可执行的 task 文件。

### 3. task 审核与实现

- 先人工审核 task 文件中的 `Implementation Plan` / `Validation Plan`。
- 审核通过后，用 `$codev-taskdev` 在 task 分支推进实现。
- `codev-taskdev` 负责代码实现、任务文档同步，以及一次实现收尾精简。

### 4. 验证与收尾

- 功能验证默认由人工完成。
- 人工确认通过后，用 `$codev-quickship` 做 task 归档、相关文档同步与主干收尾。
- 若只需要中途做一次轻量 `commit / push`，用 `$codev-checkpoint`。

## 相关文档

- skill 索引：`docs/skills/README.md`
- 仓库级事实与维护规则：`AGENTS.md`
