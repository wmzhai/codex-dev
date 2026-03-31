---
name: codev-checkpoint
description: 轻量提交当前仓库变更并推送当前分支，并默认更新根目录 `VERSION` 与已有 `CHANGELOG`；若未显式指定版本，则默认把第 4 位加一。本仓库的标准版本工件是根目录 `VERSION` 和 `CHANGELOG`。适用于用户明确要做一次 codev-checkpoint 提交，或仓库未接入 gstack `$ship` 时使用。
---

# Checkpoint

安全地提交当前工作区变更并推送。

如果仓库同时使用 gstack，默认发布入口应是 gstack `$ship`。`codev-checkpoint` 只保留为轻量 fallback：做 commit、push，并默认处理根目录 `VERSION` 与已有 `CHANGELOG`；如果用户未显式指定版本，则默认按四段版本号 `x.y.z.w -> x.y.z.(w+1)`，也就是把第 4 位加一；如果用户显式指定目标版本，则按指定值写入；但仍不接管 PR、review gate、QA 串联或 repo 级文档同步。

## 第一规则：先用中文交流

- skill 一触发，第一句就用中文和用户交流。
- 整个执行过程中的状态说明、阻塞说明和结果摘要默认都用中文。
- 只有用户明确要求英文或双语时，才切换语言。

## Inputs

从用户请求推断发布模式：

- 默认执行 commit + push，并同步版本工件。
- 只处理仓库里已经存在、且能稳定识别为 `x.y.z.w` 四段纯数字格式的根目录 `VERSION`；若未显式指定版本，则默认只把最后一位加一；若显式指定目标版本，则按指定值写入；同时最小更新仓库里已有的 `CHANGELOG`，不新建版本文件，也不打 tag。

## Workflow

1. 用非交互式 git 命令检查仓库状态，例如：
   - `git status --short --branch`
   - `git log --oneline -5`
2. 同步版本工件：
   - 先定位根目录 `VERSION`；不要自动新建版本文件。
   - 同时定位现有 `CHANGELOG`；不要自动新建 `CHANGELOG`。
   - 只接受单个、可稳定解析为 `x.y.z.w` 的四段纯数字版本号。
   - 如果用户未显式指定版本，则默认把最后一位加一，例如 `1.2.3.4 -> 1.2.3.5`。
   - 如果用户显式指定目标版本，则按指定值写入，但该版本同样必须是四段纯数字。
   - 基于本次实际 diff，对已有 `CHANGELOG` 做最小同步，记录这次小版本变更；不要扩成完整发布说明。
   - 如果不存在可用版本工件、候选不止一个、版本号不是四段格式、或仓库缺少可更新的 `CHANGELOG`，立即停止并明确说明原因。
3. 如果工作区干净，且本次也没有成功产生版本号或 `CHANGELOG` 变更，明确告知没有可提交变更并停止。
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
- 不做通用版本管理；只处理仓库里已有的四段版本号。
- checkpoint 在未显式指定版本时，默认把最后一位加一。
- 如果用户显式指定目标版本，只接受四段纯数字版本号，并按指定值写入。
- 版本同步模式下会同步更新已有 `CHANGELOG`，但不新建版本文件、不新建 `CHANGELOG`、不打 tag、也不进入 release 管理。
- 不要创建 PR、补 review gate、同步 repo 级文档；这些属于 gstack `$ship` 与 `$document-release` 的职责。
