# `$codev-checkpoint`

Source: `codev`

## Purpose

人工验证后的统一收口第一阶段：任务/验收归口、`docs`/`memory`/`AGENTS` 同步、`CHANGELOG` 未发布更新、主干提交与 issue 处理。
本阶段不做版本 bump、根 `VERSION` 修改与 tag。
用户触发即表示 `codev-taskdev` 收尾编译责任与人工功能验证已经完成；无 task 模式也表示用户已在外部完成确认。checkpoint 不负责补做 build/test/lint/typecheck 或脚本验证。

## Preconditions

- 用户触发 `$checkpoint` / `$codev-checkpoint` 且同轮已人工验证通过。
- 当前允许直接 push 主干，`CHANGELOG` 更新路径可定位。
- task 有可定位性；无 task 时以无 task 模式收口。
- task 映射 issue 时 `gh` 可用且 issue 号可解析。

## Execution（阶段一）

- 从当前工作目录定位 git 仓库根，再按该仓库本地规则纳入可见子仓；不使用其他项目路径。
- 有 task：归档到 `tasks/done/`、补充验收结论与 `Acceptance Criteria`。
- 同步本轮直接相关 `docs`、`memory`；必要时更新 `AGENTS.md`。
- 记录收口前置条件已经由用户触发确认，不运行自动验证。
- 更新 `CHANGELOG` 的未发布记录；不改写历史发布段。
- 提交并推送主干，完成后按 task 映射执行 `gh issue comment` 与 `gh issue close`。
- 明确汇报“阶段一未执行版本 bump 与 tag”。
