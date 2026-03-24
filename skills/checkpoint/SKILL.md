---
name: checkpoint
description: 轻量提交当前仓库变更并推送当前分支。适用于用户明确要做一次 checkpoint 提交，或仓库未接入 gstack `$ship` 时使用。
---

# Checkpoint

安全地提交当前工作区变更并推送。

如果仓库同时使用 gstack，默认发布入口应是 gstack `$ship`。`checkpoint` 只保留为轻量 fallback：做 commit、push，但不接管 PR、review gate、QA 串联或 repo 级文档同步。

## 第一规则：先用中文交流

- skill 一触发，第一句就用中文和用户交流。
- 整个执行过程中的状态说明、阻塞说明和结果摘要默认都用中文。
- 只有用户明确要求英文或双语时，才切换语言。

## Inputs

从用户请求推断发布模式：

- 默认执行 commit + push。

## Workflow

1. 用非交互式 git 命令检查仓库状态，例如：
   - `git status --short --branch`
   - `git log --oneline -5`
2. 如果工作区干净，明确告知没有可提交变更并停止。
3. 使用 `git add -A` 暂存所有变更，不做选择性过滤。
4. 根据 staged diff 生成简洁的 conventional commit message。
5. 用非交互方式创建 commit：
   - 不使用 `--amend`
   - 不使用 `--no-verify`
   - 不依赖交互式编辑器
6. 如果 hooks 在 commit 过程中修改了文件，重新暂存这些变更并创建第二个普通 commit，不改写刚才的提交历史。
7. 推送当前分支。
8. 返回简洁摘要，包含当前分支和结果 commit hash。

## Rules

- 把 checkpoint 视为有副作用的显式操作；不能假装完成。
- 除非用户明确要求，不要排除任何已改动文件。
- 不要重写历史。
- 如果前置条件失败，立即停止并明确说明原因。
- 不运行 CI；checkpoint 只根据当前现状做一次提交和推送。
- 不做版本号、tag 或 release 管理；这不属于 checkpoint 的职责。
- 不要创建 PR、补 review gate、同步 repo 级文档；这些属于 gstack `$ship` 与 `$document-release` 的职责。
