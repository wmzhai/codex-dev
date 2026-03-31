# Repository Guidelines

## 第一优先级：默认中文
- 强要求：除非用户明确要求英文或双语，本仓库内所有 skill 与用户的对话、进度更新、阻塞说明和结果汇报默认使用简体中文。
- 新增或修改任何 skill 时，必须在对应 `SKILL.md` 与 `agents/openai.yaml` 中保持这条中文交流约束。

## Codex First
- 新任务默认先读 `README.md`，再按问题进入 `memory/`。
- `README.md` 负责对外说明当前仓库有哪些 skills、如何安装、如何调用。
- `docs/workflows/README.md` 是总流程图与总导航。
- `docs/skills/README.md` 是所有 skill 详细手册索引。
- `memory/` 负责给 Codex 提供检索型入口、约束和维护路径。
- `memory/core/` 负责仓库总图、症状路由、稳定约束、默认工作流和 gstack 协作边界。
- 如果当前仓库同时使用 gstack，先确认任务来源：GitHub issue 或直接需求走 `codev-issue2task`，`~/.gstack/projects/` 下的设计/交接/测试计划工件走 `codev-gstack2task`。
- 维护 skills 时，优先同步 `SKILL.md`、`agents/openai.yaml`、`docs/skills/<skill>.md`、`setup`、`test/setup-smoke.sh` 和 `README.md`。

## 仓库定位
- 本仓库是 Codex skills 的集合，不是应用业务仓库。
- 每个 `skills/<name>/` 目录都是一个独立能力包，目录名必须与 `SKILL.md` 的 `name` 对齐。
- `docs/workflows/README.md` 保留完整总流程；只有总流程图中不适合一段讲清的旁支，才拆到 `docs/workflows/*.md`。
- `docs/skills/` 为每个 skill 提供单独详细手册；用户级说明优先看这里，运行规则优先回到对应 `SKILL.md`。
- `codev-memorize` 负责为项目建立或刷新 `AGENTS.md` 与 `memory/` 记忆体系，同时保留宿主代理或 gstack 需要继续留在 `CLAUDE.md` 的兼容块。
- `codev-issue2task` 保留 GitHub issue 或直接需求到 `tasks/` 的路径，不消费 gstack 工件，并直接产出可执行 plan。
- `codev-gstack2task` 负责把 `~/.gstack/projects/` 下的 gstack 工件收敛成带实现计划的 `tasks/`。
- `codev-taskdev` 负责从 `tasks/` 中选择目标 plan，在 task 分支上按已审核 `Implementation Plan` 实施代码、持续同步任务文档，并在实现收尾自动做一次语义不变精简，但不接管验证、QA、部署、归档和发布。
- `codev-simplify` 是可单独调用的语义不变精简工具，也可作为 `codev-taskdev` 的内部收尾步骤。
- `codev-quickship` 负责在用户完成人工验证后，归档 task、同步任务相关 `docs/` / `memory/` / 必要时 `AGENTS.md`，并同步根目录 `VERSION` 与 `CHANGELOG`，再把当前工作状态提交、合并并推送到 `main/master`；quickship 在未显式指定版本时默认把最后一位加一；如果 task 明确源自 GitHub issue，还要在主干 push 成功后先补一条该轮工作的评论，再通过 `gh` 关闭对应 issue；收尾提交信息应采用 `type: 具体工作摘要 (vX.Y.Z.W)` 形式；不走 PR、不打 tag，也不接管正式发布。
- `codev-checkpoint` 是轻量 `commit/push` fallback；默认会同步根目录 `VERSION` / `CHANGELOG`，且 checkpoint 在未显式指定目标版本时默认把第 4 位加一；需要 PR、review gate、QA 串联或全局文档同步时，优先使用 gstack `$ship` 与 `$document-release`。

## 维护规则
- 新增或修改 skill 时，先改 `SKILL.md`，再同步 `agents/openai.yaml` 与 `docs/skills/<skill>.md`，最后回看 `README.md`、`setup` 和 `test/setup-smoke.sh` 是否需要更新。
- `setup` 是真实安装入口；`test/setup-smoke.sh` 是安装行为的最小验证。
- 任何新增受管 skill，都必须同步到 `setup`、`README.md` 和 `test/setup-smoke.sh`。
- 修改任务入口 skill 时，保持 `codev-issue2task` 与 `codev-gstack2task` 的输入边界稳定，不要把两者揉成一个大而全入口。
- 修改 `codev-taskdev` / `codev-quickship` 时，保持“task 分支实现”和“人工验证后的主干收尾”这条边界稳定；`codev-quickship` 只负责人工验证后的归档、版本号同步、`CHANGELOG` 同步、主干收尾，以及对明确映射 issue 的 task 先评论再关闭；其中 quickship 在未显式指定版本时默认把最后一位加一，并把收尾提交信息写成 `type: 具体工作摘要 (vX.Y.Z.W)`；正式发布仍交给 gstack `$ship` / `$land-and-deploy` / `$document-release`。
- 如果仓库存在 `CLAUDE.md`，尤其已经承载 gstack section、浏览器约束或宿主代理说明，`codev-memorize` 只能收敛 repo 事实，不能把这些兼容说明删掉。
- `README.md` 里只放用户需要看到的高层说明，不重复展开各 skill 的全部内部流程。
- `docs/workflows/README.md` 要始终保持“从开始到结束”的最全总流程图。
- `docs/workflows/*.md` 只收旁支流程，不重复抄写已经在总流程中完整覆盖的主线。
