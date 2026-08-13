# Repository Guidelines

## 第一优先级：默认中文
- 强要求：除非用户明确要求英文或双语，本仓库内所有 skill 与用户的对话、进度更新、阻塞说明和结果汇报默认使用简体中文。
- 新增或修改任何 skill 时，必须在对应 `SKILL.md` 与 `agents/openai.yaml` 中保持这条中文交流约束。

## Codex First
- 新任务默认先读 `README.md`，再按问题进入 `memory/`。
- `README.md` 负责对外说明当前仓库有哪些 skills、如何安装、如何调用。
- `docs/workflows.md` 是唯一工作流导航。
- `docs/skills/README.md` 是所有 skill 详细手册索引。
- `memory/` 负责给 Codex 提供检索型入口、约束和维护路径。
- `memory/core/` 负责仓库总图、症状路由、稳定约束和默认工作流。
- 维护 skills 时，优先同步 `SKILL.md`、`agents/openai.yaml`、`docs/skills/<skill>.md`、`setup`、`test/setup-smoke.sh` 和 `README.md`。

## 仓库定位
- 本仓库是 Codex skills 的集合，不是应用业务仓库。
- 每个 `skills/<name>/` 目录都是一个独立能力包，目录名必须与 `SKILL.md` 的 `name` 对齐。
- `docs/workflows.md` 保留完整的 codev 工作流说明。
- `docs/skills/` 只为当前受管的 codev skill 提供详细手册；用户级说明优先看这里，运行规则优先回到对应 `SKILL.md`。
- `codev-memorize` 负责为项目建立或刷新 `AGENTS.md` 与 `memory/` 记忆体系，默认入口统一收敛到 `AGENTS.md + memory/`。
- `codev-issue2task` 保留 GitHub issue 或直接需求到 `tasks/` 的路径，并直接产出可执行 plan。
- `codev-taskdev` 负责从 `tasks/` 中选择目标 plan，在 task 分支上按已审核 `Implementation Plan` 实施代码、持续同步任务文档，并在实现收尾自动做一次语义不变精简和一次默认 build / 最小编译校验；这是 quickship/checkpoint 之前唯一由 codev 自动承担的编译校验责任点，但不接管自动化功能验证、QA、部署、归档和发布。
- `codev-simplify` 是可单独调用的语义不变精简工具，也可作为 `codev-taskdev` 的内部收尾步骤。
- `codev-quickship` 与 `codev-checkpoint` 的主流程统一。quickship 在 checkpoint 流程基础上额外执行 `VERSION` 同步与 tag 推送；checkpoint 不做版本 bump 和 tag 动作。两者都可归档可定位 task、更新 `CHANGELOG` 未发布记录并提交推送当前分支；用户触发 quickship/checkpoint 即表示 `codev-taskdev` 收尾校验和人工验证已经完成，收口阶段不再运行 build/test/lint/typecheck 或脚本验证。
- `codev-checkpoint` 是轻量 `commit/push` fallback。默认同步已有 `CHANGELOG` 的未发布记录，存在可定位当前任务时会补齐该任务记录并归档到 `tasks/done/`，但不修改根目录 `VERSION`、不创建或推送 tag；其主流程与 `codev-quickship` 一致。
- 若仓库里没有可定位 task，则 quickship 按无 task 模式收尾，但同样依赖用户触发前已完成外部确认；quickship 优先遵守仓库本地版本规则，没有本地规则时接受三段或四段数字版本，并递增版本号最后一段，tag 默认使用 `v<VERSION>`。
- `codev-syncpatch` 负责在不提交、不 push、不默认创建分支的前提下，同步开源 upstream 并按原意重放本地运行补丁；如果同步前无法高置信度判断可完整补回本地逻辑，必须先停下和用户确认。

## 维护规则
- 新增或修改 skill 时，先改 `SKILL.md`，再同步 `agents/openai.yaml` 与 `docs/skills/<skill>.md`，最后回看 `README.md`、`setup` 和 `test/setup-smoke.sh` 是否需要更新。
- `setup` 是真实安装入口，必须同时刷新 Codex（`~/.codex/skills`）和 Grok（`~/.grok/skills`）；`test/setup-smoke.sh` 是安装行为的最小验证。
- 任何新增受管 skill，都必须同步到 `setup`、`README.md` 和 `test/setup-smoke.sh`。
- 修改任务入口 skill 时，保持 `codev-issue2task` 作为唯一任务生成入口，不要把任务规划、实现、收尾揉成一个大而全入口。
- 修改 `codev-taskdev` / `codev-quickship` / `codev-checkpoint` 时，保持“task 分支实现”和“人工验证后的主干收尾”这条边界稳定；`codev-taskdev` 负责实现收尾阶段的一次默认 build / 最小编译校验；`codev-quickship` 与 `codev-checkpoint` 主流程一致，唯一差异是 quickship 额外处理版本 bump 与 tag 推送，checkpoint 不处理版本与 tag；收口 skill 不补做 build/test/lint/typecheck 或脚本验证；若仓库里没有可定位 task，仍可按无 task 模式继续流程。
- `codev-memorize` 统一将仓库事实与约束收敛到 `AGENTS.md + memory/`，不再维护额外入口文件。
- `README.md` 里只放用户需要看到的高层说明，不重复展开各 skill 的全部内部流程。
- `docs/workflows.md` 要始终保持从开始到结束的 codev 主流程说明。
