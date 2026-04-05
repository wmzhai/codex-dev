# `$codev-checkpoint`

Source: `codev`

## Purpose

对当前分支做一次轻量 commit + push，并默认更新根目录 `VERSION` 与已有 `CHANGELOG`。如果未显式指定版本，则默认按四段版本号 `x.y.z.w -> x.y.z.(w+1)`，也就是把最后一位加一。本仓库里标准的版本工件是根目录 `VERSION` 和 `CHANGELOG`。它只负责轻量提交，不接管更大的发布或审查流程。

## Preconditions

- 当前工作区存在可提交改动，或者本次版本号 / `CHANGELOG` 同步可以产生可提交变更。
- 用户明确要做一次轻量 checkpoint。
- 接受它只是 fallback，而不是正式发布入口。
- 仓库里必须已存在且只能明确识别出一个 `x.y.z.w` 四段纯数字的根目录 `VERSION`，并且已有可更新的 `CHANGELOG`。

## Inputs / Source Of Truth

- 当前工作区 diff
- 当前分支状态
- 最近提交历史
- 若适用，现有根目录 `VERSION`
- 若适用，现有 `CHANGELOG`

## Produces / Writes

- 一次或多次普通 commit
- 当前分支 push 结果
- 若适用，版本号同步结果
- 若适用，`CHANGELOG` 最小同步结果

## Execution Flow

1. 检查分支、工作区和最近提交历史。
2. 同步仓库里已存在的单个四段纯数字 `VERSION`；若未显式指定版本，则默认只把最后一位加一；若显式指定目标版本，则按指定值写入；同时最小更新已有 `CHANGELOG`；不存在、歧义或格式不符时停止。
3. 若工作区为空，且本次也没有成功产生版本号或 `CHANGELOG` 变更，则明确告知没有可提交内容并停止。
4. 暂存当前改动，生成简洁的 commit message。
5. 用非交互方式创建 commit；如 hook 改了文件，再补一次普通 commit。
6. 推送当前分支。
7. 向用户报告分支名、提交结果、commit hash，以及是否执行了版本号同步和 `CHANGELOG` 同步。

## Stops / Failure Modes

- 工作区为空，且本次也没有成功产生版本号或 `CHANGELOG` 变更。
- push 失败或权限不足。
- hook 失败，导致 commit 无法完成。
- 用户要求同步版本，但版本工件不存在、候选不唯一、不是四段格式，或仓库缺少可更新的 `CHANGELOG`。

## Next Recommended Steps

- 继续本仓库的人工验证流程
- 需要归档和主干收尾时，进入 `$codev-quickship`
