# `$codev-simplify`

Source: `codev`

## Purpose

在保持行为不变的前提下收窄当前 diff，降低嵌套和重复，让 patch 更易审查，也更容易进入 checkpoint 或任务收尾。

## Preconditions

- 当前存在明确的、最小范围的相关 diff。
- 用户接受“只做语义不变精简”，而不是功能开发。
- 不要求 clean tree，但要能明确区分本次要精简的 patch 范围。

## Inputs / Source Of Truth

- 当前工作区 diff
- 相关代码上下文
- 周边既有代码风格和惯用写法

## Produces / Writes

- 更小、更清晰但语义等价的代码 diff

## Execution Flow

1. 先阅读当前 diff 和周边上下文，确认真正要精简的范围。
2. 找出可以安全消除的重复逻辑、冗余分支和临时状态。
3. 优先做低风险变换，例如合并条件、内联单次使用变量、收窄局部命名。
4. 不扩大范围，不改公共 API，不引入新依赖。
5. 重新核对边界情况与错误路径，确认行为未变。
6. 只返回简短摘要，不默认贴完整 patch。

## Stops / Failure Modes

- 无法保证行为不变。
- patch 范围过大，无法安全判断哪些改动属于“精简”。
- 精简必须依赖功能重写或 API 变化。

## Next Recommended Steps

- 普通 commit 或 `$codev-checkpoint`
- 在 `$codev-taskdev` 内作为实现收尾精简步骤被调用
- 人工验证通过后进入 `$codev-quickship`
