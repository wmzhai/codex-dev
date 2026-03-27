# `$codev-checkpoint`

Source: `codev`

## Purpose

对当前分支做一次轻量 commit + push；当用户明确要求时，可额外把仓库里现有四段版本号的最后一位加一，并同步更新已有 `CHANGELOG`。不接管 PR、review gate、QA 串联或 repo 级文档同步。

## Preconditions

- 当前工作区存在可提交改动；或者用户明确要求 bump 小版本号，并且版本文件与 `CHANGELOG` 条件满足。
- 用户明确要做一次轻量 checkpoint。
- 接受它只是 fallback，而不是正式发布入口。
- 如果用户要求 bump 小版本号，仓库里必须已存在且只能明确识别出一个 `x.y.z.w` 四段纯数字版本工件，并且已有可更新的 `CHANGELOG`。

## Inputs / Source Of Truth

- 当前工作区 diff
- 当前分支状态
- 最近提交历史
- 若适用，现有四段版本号工件
- 若适用，现有 `CHANGELOG`

## Produces / Writes

- 一次或多次普通 commit
- 当前分支 push 结果
- 若适用，版本号末位自增结果
- 若适用，`CHANGELOG` 最小同步结果

## Execution Flow

1. 检查分支、工作区和最近提交历史。
2. 如果用户明确要求 bump 小版本号，只处理仓库里已存在的单个四段纯数字版本号，并且只把最后一位加一；同时最小更新已有 `CHANGELOG`；不存在、歧义或格式不符时停止。
3. 若工作区为空，且本次也没有成功产生版本号或 `CHANGELOG` 变更，则明确告知没有可提交内容并停止。
4. 暂存当前改动，生成简洁的 commit message。
5. 用非交互方式创建 commit；如 hook 改了文件，再补一次普通 commit。
6. 推送当前分支。
7. 向用户报告分支名、提交结果、commit hash，以及是否执行了版本号末位自增和 `CHANGELOG` 同步。

## Stops / Failure Modes

- 工作区为空，且本次也没有成功产生版本号或 `CHANGELOG` 变更。
- push 失败或权限不足。
- hook 失败，导致 commit 无法完成。
- 用户要求 bump 小版本号，但版本工件不存在、候选不唯一、不是四段格式，或仓库缺少可更新的 `CHANGELOG`。

## Next Recommended Steps

- 继续 `$design-review`、`$review`、`$qa`
- 正式发布仍应进入 `$ship`
