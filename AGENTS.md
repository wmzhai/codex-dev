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
- `codev-memorize` 负责为项目建立或刷新 `AGENTS.md` 与 `memory/` 记忆体系，同时保留宿主代理说明。
- `codev-issue2task` 保留 GitHub issue 或直接需求到 `tasks/` 的路径，并直接产出可执行 plan。
- `codev-taskdev` 负责从 `tasks/` 中选择目标 plan，在 task 分支上按已审核 `Implementation Plan` 实施代码、持续同步任务文档，并在实现收尾自动做一次语义不变精简和一次默认 build / 最小编译校验，但不接管自动化功能验证、QA、部署、归档和发布。
- `codev-simplify` 是可单独调用的语义不变精简工具，也可作为 `codev-taskdev` 的内部收尾步骤。
- `codev-quickship` 负责在用户完成人工验证后，优先按 task 归档并同步任务相关 `docs/` / `memory/` / 必要时 `AGENTS.md`；若存在 task，则默认沿用 `codev-taskdev` 收尾阶段已完成的默认 build / 最小编译校验，不在 quickship 内重复执行；若仓库里没有可定位 task，则 quickship 按无 task 模式收尾，并在版本同步与主干收尾前补跑一次仓库默认 build / 最小编译校验，跳过 task 归档与 issue 关闭，但必须在 `CHANGELOG` 里记录本轮相关改动摘要；随后再同步根目录 `VERSION` 与 `CHANGELOG`，并把当前工作状态提交、合并并推送到 `main/master`；quickship 在未显式指定版本时默认把 `VERSION` 的补丁位加一；如果 task 明确源自 GitHub issue，还要在主干 push 成功后先补一条该轮工作的评论，再通过 `gh` 关闭对应 issue；收尾提交信息应采用 `type: 具体工作摘要 (vX.Y.Z)` 形式；不走 PR、不打 tag。
- `codev-checkpoint` 是轻量 `commit/push` fallback，默认不同步根目录 `VERSION` / `CHANGELOG`，仅在用户显式要求时才处理版本工件。
- `codev-syncpatch` 负责在不提交、不 push、不默认创建分支的前提下，同步开源 upstream 并按原意重放本地运行补丁；如果同步前无法高置信度判断可完整补回本地逻辑，必须先停下和用户确认。

## 维护规则
- 新增或修改 skill 时，先改 `SKILL.md`，再同步 `agents/openai.yaml` 与 `docs/skills/<skill>.md`，最后回看 `README.md`、`setup` 和 `test/setup-smoke.sh` 是否需要更新。
- `setup` 是真实安装入口；`test/setup-smoke.sh` 是安装行为的最小验证。
- 任何新增受管 skill，都必须同步到 `setup`、`README.md` 和 `test/setup-smoke.sh`。
- 修改任务入口 skill 时，保持 `codev-issue2task` 作为唯一任务生成入口，不要把任务规划、实现、收尾揉成一个大而全入口。
- 修改 `codev-taskdev` / `codev-quickship` 时，保持“task 分支实现”和“人工验证后的主干收尾”这条边界稳定；`codev-taskdev` 负责实现收尾阶段的一次默认 build / 最小编译校验；`codev-quickship` 只负责人工验证后的归档、无 task 或用户明确要求复验时的默认 build、版本同步、`CHANGELOG` 同步、主干收尾，以及对明确映射 issue 的 task 先评论再关闭；若仓库中没有可定位 task，则 quickship 允许按无 task 模式收尾，但必须在 `CHANGELOG` 里补本轮改动摘要；其中 quickship 在未显式指定版本时默认把 `VERSION` 的补丁位加一，并把收尾提交信息写成 `type: 具体工作摘要 (vX.Y.Z)`。
- 如果仓库存在 `CLAUDE.md`，`codev-memorize` 只能收敛 repo 事实，不能把宿主兼容说明删掉。
- `README.md` 里只放用户需要看到的高层说明，不重复展开各 skill 的全部内部流程。
- `docs/workflows.md` 要始终保持从开始到结束的 codev 主流程说明。
