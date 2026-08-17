---
name: codev-checkpoint
description: 人工验证通过后的统一收口第一阶段：任务归档、验收更新、`CHANGELOG` 同步、主干提交与 issue 处理，不做版本 bump、tag 或自动验证。
---

# Checkpoint

## 第一规则：先用中文交流

- skill 一触发，第一句就用中文和用户交流。
- 整个执行过程中的检查、阻塞说明和结果摘要默认都用中文。
- 只有用户明确要求英文或双语时，才切换语言。

## 作用与边界

`codev-checkpoint` 仅执行收口第一阶段。
本阶段必须包含除版本号与 tag 外的全部核心收口动作，且必须产出收口 `commit` 并推送主干（或分支后合并到主干）。
版本 bump、`VERSION` 工件变更、版本日志归并与 tag 推送，不在本阶段执行。
当被 `codev-quickship` 内嵌调用时，本阶段只做收口一致性检查并把结果交给 quickship 第二阶段统一提交；不得在内嵌阶段提交或 push。
用户触发即表示 `codev-taskdev` 收尾编译责任与人工功能验证已经完成；无 task 模式也表示用户已在外部完成确认。本阶段不负责补做 build/test/lint/typecheck 或脚本验证。

## Preconditions

- 用户显式调用 `checkpoint` / `codev-checkpoint`（Codex 为 `$...`，Grok 为 `/...`），且本轮已完成人工验证；用户触发即表示相关实现收尾检查已在外部完成。
- 当前仓库允许直接推送主干；若主干受保护、权限不足或必须走 PR，立即阻塞。
- 收口范围从当前工作目录解析：先定位当前 git 仓库根；若该仓库本地规则（如根 `AGENTS.md`）明确列出可见子仓，则一并纳入，不按来源推断过滤。
- 禁止使用 skill 文本、历史会话或其他项目中的绝对路径作为默认工作区。
- 若可定位 task：必须能稳定找到；若仓库无对应 task 则进入无 task 收口，不得伪造 task。
- 若 task 映射 issue，需本地 `gh` 可用且能稳定解析 issue 号；否则阻塞并说明。
- `CHANGELOG` 写入位点必须可定位；若仓库规则要求更新却无法定位，立即停止。

## Inputs

- 当前分支与目标主干。
- 可定位的 `tasks/Txx-*.md` 与 issue 映射信息。
- 当前未提交改动范围（根仓库 + 可见子仓）。
- `CHANGELOG` 的更新规则与可写路径。

## Workflow（第一阶段）

1. 读取本地规则并校验前置条件。
2. 定位任务（优先级）：
   - 用户显式 task；
   - 与当前分支同名的 `tasks/Txx-*.md`；
   - 否则无 task 收口。
3. 列出未提交改动并确认收口范围。
4. 有 task 时执行任务收口：
   - 更新人工验收结论、风险与后续项；
   - 补齐 `Acceptance Criteria` / `验收标准` 的通过项；
   - 使用 `git mv` 把 task 移入 `tasks/done/`（目录不存在先创建）。
5. 同步任务相关文档：
   - 更新与任务直接相关且已确认的 `docs/`、`memory/`；
   - 任务涉及工作流/约束变更时更新 `AGENTS.md`；
   - 无 task 时仅做本轮改动直接相关的最小同步，无需更新则写明。
6. 收口前置确认（不执行自动验证）：
   - 记录用户触发即表示 `codev-taskdev` 收尾编译责任与人工验证已经完成；
   - 无 task 模式同样依赖用户在触发前完成外部确认；
   - 不运行 build/test/lint/typecheck 或脚本验证，也不要求收口阶段补齐验证记录。
7. `CHANGELOG` 同步：
   - 仅更新未发布区（如 `[Unreleased]` / `[未发布]`）；
   - 不改写历史发布段；
   - 不做版本归并（与 version 阶段无关）。
8. 收口提交与主干推送：
   - 当前在分支：先提交后合并到主干；
   - 当前在主干：直接形成主干收口提交；
   - commit message 为普通描述，不带版本后缀。
9. issue 处理（仅当映射存在且主干推送成功）：
   - 先逐个 `gh issue comment`；
   - 再逐个 `gh issue close`；
   - 逐项记录失败与阻塞原因。
10. 返回阶段一结果：
   - 任务归档、`docs/memory/AGENTS`、`CHANGELOG`、issue 处理、主干提交与推送；
   - 明确写明本阶段未执行版本 bump 与 tag。

## Stops / Failure Modes

- 前置条件失败（主干权限、`CHANGELOG` 不可更新、issue 映射不可解析）。
- 无法确认且安全地纳入未提交改动。
- `git` 提交/推送失败。
- 任一阻塞点需立即返回并停止，禁止继续版本阶段。

## Rules

- 不创建 PR，不接管发布链路。
- 不重写历史（包括 amend）。
- 不执行本阶段版本推导、`VERSION` 编辑、tag 创建与推送。
- 只在 stage1 成功后方可进入版本阶段。
- 独立 checkpoint 与 quickship 内嵌 checkpoint 都只做收口动作；自动编译责任固定在 `codev-taskdev`，功能正确性由用户人工确认。
