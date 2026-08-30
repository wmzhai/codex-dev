# `$codev-issue2task`

Source: `codev`

## Purpose

把 GitHub issue 或用户直接需求结合当前代码，先通过中文讨论把需求边界、实现方向和验证方式确认清楚，再压成 repo 内可执行的 task 文件；支持把多个 issue 编号合并成一个总体 task，适合做版本级合并实现。也支持 `<subdir>#70` 这种 `子目录#编号` 参数，用来从当前目录定位子目录里的目标仓库 issue。

## Preconditions

- 当前目录是 git 仓库；如果使用 `子目录#编号` 参数，则对应子目录是 git 仓库。
- 如果输入来自 GitHub issue，则 `gh` 可用。
- 允许在目标仓库中新建 `tasks/Txx-*.md`。

## Inputs / Source Of Truth

- GitHub issue、多个 issue 编号列表、issue 列表过滤条件，或用户直接需求
- `<subdir>#70` 这样的子目录 issue 引用，其中 `<subdir>` 是当前目录下的目标仓库子目录，`70` 是该仓库的 GitHub issue 编号
- 目标仓库的当前代码现状
- 现有 `tasks/` 与 `tasks/done/`
- 现有分支与依赖任务状态

## Produces / Writes

- 一个或多个 `tasks/Txx-*.md`
- 文件中的 `Implementation Plan`、`Validation Plan`、`Related Code`

## Common Invocations

Codex 用 `$` 前缀；Grok 与 Claude Code 把 `$` 换成 `/`，例如 `/codev-issue2task <subdir>#70`。

- `$codev-issue2task`
- `$codev-issue2task 42`
- `$codev-issue2task <subdir>#70`
- `$codev-issue2task 42 43 44`
- `$codev-issue2task 42,43,44`
- `$codev-issue2task <subdir>#70 <subdir>#71`

显式传入多个 issue 编号时，支持逗号、空格或混合分隔，默认会为这组 issue 生成一个总体 task。
传入 `<subdir>#70` 时，当前目录下的 `<subdir>/` 会成为目标仓库；后续 issue 读取、代码阅读、任务查重和 `tasks/` 写入都在该子目录内完成。子目录名由用户参数决定，不写死某个项目。多个带子目录前缀的 issue 引用必须指向同一个子目录，不要把多个子仓库的 issue 合并到同一个 task。

## Execution Flow

1. 识别目标仓库和输入源：当前仓库单 issue、显式多个 issue 编号、`<subdir>#70` 这样的子目录 issue、多 issue 过滤、或直接需求文本。
2. 如果输入是 `子目录#编号`，先进入该子目录目标仓库，再读取对应 issue；如果多个子目录前缀不一致，停止并要求拆成多次调用。
3. 深读目标仓库相关代码，确认当前行为、边界条件、关键模块和约束。
4. 先输出一轮需求理解、关键假设、待确认点和推荐实现方向，按固定提纲和用户完成讨论确认。
5. 只有在用户明确确认后，才收敛需求边界、验收标准、out-of-scope 和推荐实现路径。
6. 判断是否需要拆成多个 task，默认保守拆分；显式多个 issue 编号时默认合并成一个总 task。
7. 在目标仓库内计算新任务编号，避免与 `tasks/`、`tasks/done/` 冲突。
8. 默认不新建分支、不切分支，直接在当前分支写入完整 task 文件；只有用户明确要求时才创建或切换分支。

## Standard Discussion Outline

确认回合建议固定按以下顺序输出：

1. 问题复述
2. 当前代码现状
3. 关键判断
4. 待确认清单
5. 推荐方案
6. 确认门禁

推荐的模板句式：

```text
我对这个 issue 的理解是：
- ...

我看到的代码现状是：
- ...

这里有几个会影响实现的待确认点：
1. ...
2. ...
3. ...

我的默认方案是：
- ...

如果你确认以上理解，我再把它写成 task 文件。
```

## Stops / Failure Modes

- 需要 issue 但 `gh` 不可用。
- `子目录#编号` 指向的子目录不存在，或该子目录不是 git 仓库。
- 一次调用里混合了多个不同子目录的 issue 引用。
- 关键需求歧义会显著改变实现路径，且无法从代码推断。
- 用户尚未明确确认需求细节，却要求直接落 task。
- 当前工作区状态无法安全切分支。

## Next Recommended Steps

- 人工审核 task plan
- 认可后进入 `codev-taskdev`（Codex：`$codev-taskdev`，Grok：`/codev-taskdev`，Claude Code：`/codev-taskdev`）
