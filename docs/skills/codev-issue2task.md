# `$codev-issue2task`

Source: `codev`

## Purpose

把 GitHub issue 或用户直接需求结合当前代码，压成 repo 内可执行的 task 文件和 task 分支；支持把多个 issue 编号合并成一个总体 task，适合做版本级合并实现。

## Preconditions

- 当前目录是 git 仓库。
- 如果输入来自 GitHub issue，则 `gh` 可用。
- 允许新建 `tasks/Txx-*.md` 与对应分支。

## Inputs / Source Of Truth

- GitHub issue、多个 issue 编号列表、issue 列表过滤条件，或用户直接需求
- 当前代码现状
- 现有 `tasks/` 与 `tasks/done/`
- 现有分支与依赖任务状态

## Produces / Writes

- 一个或多个 `tasks/Txx-*.md`
- 对应 task 分支
- 文件中的 `Implementation Plan`、`Validation Plan`、`Related Code`

## Common Invocations

- `$codev-issue2task`
- `$codev-issue2task 42`
- `$codev-issue2task 42 43 44`
- `$codev-issue2task 42,43,44`

显式传入多个 issue 编号时，支持逗号、空格或混合分隔，默认会为这组 issue 生成一个总体 task。

## Execution Flow

1. 识别输入源：单 issue、显式多个 issue 编号、多 issue 过滤、或直接需求文本。
2. 深读相关代码，确认当前行为、边界条件、关键模块和约束。
3. 收敛需求边界、验收标准、out-of-scope 和推荐实现路径。
4. 判断是否需要拆成多个 task，默认保守拆分；显式多个 issue 编号时默认合并成一个总 task。
5. 计算新任务编号，避免与 `tasks/`、`tasks/done/` 冲突。
6. 为每个 task 新建分支，并写入完整 task 文件。

## Stops / Failure Modes

- 需要 issue 但 `gh` 不可用。
- 关键需求歧义会显著改变实现路径，且无法从代码推断。
- 当前工作区状态无法安全切分支。

## Next Recommended Steps

- 人工审核 task plan
- 认可后进入 `$codev-taskdev`
- 若想自动闭环，直接进入 `$codev-autodev`
