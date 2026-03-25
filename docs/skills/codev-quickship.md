# `$codev-quickship`

Source: `codev`

## Purpose

在用户确认当前结果后，快速把当前工作状态直推主干：如果在分支上就先合并到主干，如果已经在主干就直接提交并推送；不走 PR、版本号或正式发布流程。

## Preconditions

- 用户已经明确确认当前结果符合预期，并接受直接 push 主干。
- 当前仓库允许直接推送 `main/master` 或默认主干。

## Inputs / Source Of Truth

- 当前 git 分支
- 仓库默认主干，或 `main/master`
- 可选的对应 `tasks/Txx-*.md`

## Produces / Writes

- 主干合并结果
- 主干推送结果
- 可选的 task 文档最小同步

## Execution Flow

1. 以当前 git 分支为起点，确认用户已经明确允许直接推主干。
2. 检查工作区与主干权限，必要时先做最小提交或停止。
3. 如果当前在分支上，同步远端主干并在本地完成 merge；如果已经在主干上，直接在主干提交这次小改动。
4. 直接 push 主干。
5. 如存在对应 task，最小范围补记 quickship 事实。

## Stops / Failure Modes

- 用户没有明确确认。
- 主干受保护、权限不足或必须走 PR。
- 合并冲突无法安全收敛。

## Next Recommended Steps

- 小改动快速收口后继续开发下一个任务
- 如果需要正式发布、版本号或 repo 级文档同步，改走 `$codev-automerge` 或 gstack 发布链路
