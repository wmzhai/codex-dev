---
name: codev-checkpoint
description: 轻量提交当前仓库变更并推送当前分支。适用于用户明确要做一次 codev-checkpoint 提交，且只想在必要时顺手同步已有 `VERSION` / `CHANGELOG`。
---

# Checkpoint

安全地提交当前工作区变更并推送。

如果仓库同时使用 gstack，默认发布入口应是 gstack `$ship`。`codev-checkpoint` 只保留为轻量 fallback：做 commit、push，但不默认处理根目录 `VERSION` 或已有 `CHANGELOG`；除非用户明确要求同步版本工件，否则它只提交当前现有改动，不接管 PR、review gate、QA 串联或 repo 级文档同步。

## 第一规则：先用中文交流

- skill 一触发，第一句就用中文和用户交流。
- 整个执行过程中的状态说明、阻塞说明和结果摘要默认都用中文。
- 只有用户明确要求英文或双语时，才切换语言。

## Inputs

从用户请求推断发布模式：

- 默认执行 commit + push，不默认同步版本工件。
- 只有当用户明确要求同步版本时，才处理仓库里已经存在的根目录 `VERSION` 与已有 `CHANGELOG`；不新建版本文件，也不打 tag。

## Workflow

1. 用非交互式 git 命令检查仓库状态，例如：
   - `git status --short --branch`
   - `git log --oneline -5`
2. 仅当用户明确要求同步版本工件时：
   - 先定位根目录 `VERSION`；不要自动新建版本文件。
   - 同时定位现有 `CHANGELOG`；不要自动新建 `CHANGELOG`。
   - 只接受单个、可稳定解析的 `X.Y.Z` 版本号。
   - 如果用户显式指定目标版本，则按指定值写入，该版本同样必须符合 `X.Y.Z`。
   - 基于本次实际 diff，对已有 `CHANGELOG` 做最小同步，记录这次变更；不要扩成完整发布说明。
   - 如果不存在可用版本工件、候选不止一个、版本号格式不符、或仓库缺少可更新的 `CHANGELOG`，立即停止并明确说明原因。
3. 如果工作区干净，且本次也没有产生可提交变更，明确告知没有可提交内容并停止。
4. 使用 `git add -A` 暂存所有变更，不做选择性过滤。
5. 根据 staged diff 生成简洁的 conventional commit message。
6. 用非交互方式创建 commit：
   - 不使用 `--amend`
   - 不使用 `--no-verify`
   - 不依赖交互式编辑器
7. 如果 hooks 在 commit 过程中修改了文件，重新暂存这些变更并创建第二个普通 commit，不改写刚才的提交历史。
8. 推送当前分支。
9. 返回简洁摘要，包含当前分支、结果 commit hash，以及是否执行了版本号同步和 `CHANGELOG` 同步。

## Rules

- 把 codev-checkpoint 视为有副作用的显式操作；不能假装完成。
- 除非用户明确要求，不要排除任何已改动文件。
- 不要重写历史。
- 如果前置条件失败，立即停止并明确说明原因。
- 不运行 CI；codev-checkpoint 只根据当前现状做一次提交和推送。
- 不做通用版本管理；默认不改 `VERSION`。
- checkpoint 不默认同步 `VERSION`，也不默认同步 `CHANGELOG`。
- 如果用户显式指定目标版本，只接受 `X.Y.Z` 版本号，并按指定值写入。
- 版本同步模式下才更新已有 `CHANGELOG`，但不新建版本文件、不新建 `CHANGELOG`、不打 tag、也不进入 release 管理。
- 不要创建 PR、补 review gate、同步 repo 级文档；这些属于 gstack `$ship` 与 `$document-release` 的职责。
