# Skill 手册索引

这里收录本仓库当前仍受管的 codev 自定义 skill 说明。想先看整体流程，先回到 `docs/workflows.md`。

## 命名约定

- codev 自定义 skill：使用 `codev-*` 前缀。

## 1. 仓库初始化与记忆

- [codev-memorize](codev-memorize.md)：初始化或刷新仓库级记忆入口。

## 2. 任务生成

- [codev-issue2task](codev-issue2task.md)：把 issue 或直接需求整理成可执行 task。

## 3. task 分支实现与收口

- [codev-taskdev](codev-taskdev.md)：按已审核 task 在任务分支推进实现，并在收尾自动做一次语义不变精简和默认 build 校验。
- [codev-quickship](codev-quickship.md)：人工验证通过后的统一收尾；有 task 时沿用 taskdev 的默认 build，无 task 时补跑，支持有 task 和无 task 两种模式。
- [codev-simplify](codev-simplify.md)：做语义不变的精简，可单独调用。
- [codev-checkpoint](codev-checkpoint.md)：做一次轻量 `commit / push`；默认不升级版本号。
