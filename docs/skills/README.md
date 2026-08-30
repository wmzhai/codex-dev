# Skill 手册索引

这里收录本仓库当前仍受管的 codev 自定义 skill 说明。想先看整体流程，先回到 `docs/workflows.md`。

## 命名约定

- codev 自定义 skill：使用 `codev-*` 前缀。
- 用户对话里的调用前缀：Codex 用 `$codev-*`，Grok 和 Claude Code 用 `/codev-*`。落盘文档同时写三家。

## 1. 仓库初始化与记忆

- [codev-memorize](codev-memorize.md)：初始化或刷新仓库级记忆入口。

## 2. 任务生成

- [codev-issue2task](codev-issue2task.md)：把 issue 或直接需求整理成可执行 task。

## 3. task 分支实现与收口

- [codev-taskdev](codev-taskdev.md)：按已审核 task 在任务分支推进实现，并在收尾自动做一次语义不变精简和默认 build 校验；这是 quickship/checkpoint 前唯一由 codev 自动承担的编译校验责任点。
- [codev-quickship](codev-quickship.md)：人工验证通过后的统一收尾，主流程与 checkpoint 一致，只额外做 `VERSION` 同步与 tag 推送，不补做自动验证。
- [codev-simplify](codev-simplify.md)：做语义不变的精简，可单独调用。
- [codev-checkpoint](codev-checkpoint.md)：做一次轻量 `commit / push`；主流程与 quickship 一致，不升级版本号和 tag，不补做自动验证。

## 4. 开源上游同步

- [codev-syncpatch](codev-syncpatch.md)：同步 upstream 最新代码，并按原意重放本地运行补丁；默认不提交、不 push、不默认创建分支。
