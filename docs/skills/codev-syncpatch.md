# `$codev-syncpatch`

Source: `codev`

## Purpose

在长期跟踪开源仓库时，把 upstream 最新代码同步到本地，同时保留本地为了正常运行而维护的必要补丁。它不是提交或发布流程，只负责安全保存、同步和按原始意图重放本地修改。

## Preconditions

- 当前仓库有可识别的 upstream，例如 `origin/main`。
- 用户希望保留本地未提交补丁，并同步 upstream 最新代码。
- 接受默认不创建 commit、不 push、不默认创建分支。
- 当前仓库不处于 merge、rebase 或 cherry-pick 中。

## Inputs / Source Of Truth

- 当前工作区 diff、staged diff 和未跟踪文件。
- 当前分支 upstream 与 ahead/behind 状态。
- upstream 相对当前 HEAD 的文件变化。
- 本地补丁的行为意图和可验证路径。

## Produces / Writes

- `.git/codev-syncpatch/<timestamp>/` 下的补丁备份。
- 一个保留的 `codev-syncpatch:<timestamp>` stash。
- 同步后的工作区本地补丁。
- 验证结果摘要。

它不产生 commit、不 push、不默认创建分支。

## Execution Flow

1. 检查工作区、暂存区、未跟踪文件、upstream 和当前仓库操作状态。
2. 在 `.git/codev-syncpatch/<timestamp>/` 保存 status、staged/unstaged patch、未跟踪文件清单，必要时保存未跟踪文件 tar。
3. `git fetch --prune` 后比较 upstream 变化，并先判断本地补丁是否能高置信度按原意补回。
4. 如果不能确认可完整补回，先向用户说明风险，等待用户选择退出、分阶段处理、只保留备份或改变策略。
5. 能确认时，用 `git stash push -u` 保存改动，再执行 `git pull --ff-only`。
6. 用 `git stash apply` 把本地补丁补回最新代码；出现冲突时按本地意图重新实现，不做机械 ours/theirs。
7. 运行与补丁相关的最小验证。
8. 报告同步结果、保留的本地补丁、验证结果、stash 和备份目录。

## Stops / Failure Modes

- 当前仓库处于 merge/rebase/cherry-pick 中。
- 没有 upstream 或 upstream 状态无法判断。
- 无法高置信度判断本地补丁能完整重放。
- `git pull --ff-only` 失败，说明历史不是简单快进。
- 冲突重放阶段发现需要产品或实现取舍。
- 相关验证失败且无法在当前上下文确认修复方式。

## Next Recommended Steps

- 人工确认本地补丁在最新代码上运行正常。
- 如果补丁稳定且需要长期保留，继续用 `$codev-syncpatch` 维护。
- 如果要提交本地补丁到自己的分支，再明确进入 `$codev-checkpoint` 或其他发布流程。
