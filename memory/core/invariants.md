# Invariants

## 安装与发现
- `setup` 必须把 `codev` 本身链接到目标宿主的全局 skills 目录：`~/.codex/skills/codev` 和/或 `~/.claude/skills/codev`；默认无参时同时安装 Claude 与 Codex，显式 `--host` 时只安装指定宿主。
- 受管 skills 必须通过 `setup` 一次性链接，不手工散装维护。
- `test/setup-smoke.sh` 必须覆盖受管 skills 的链接列表。

## 目录约束
- `skills/<name>/` 目录名必须和 `SKILL.md` 的 `name` 一致。
- `SKILL.md` 负责工作流；`agents/openai.yaml` 负责 UI 元数据。
- `README.md` 是仓库级导航，不替代 `SKILL.md`。
- `docs/workflows.md` 必须保留唯一工作流导航。
- `docs/skills/<skill>.md` 必须覆盖对应 skill 的详细手册。

## 内容约束
- `SKILL.md` 的 `description` 必须同时说明“做什么”和“什么时候用”。
- 新增 skill 时，README、setup、smoke test 必须同步。
- `codev-memorize` 的职责是建立或刷新 `AGENTS.md` 与 `memory/`，不负责业务逻辑。
- `codev-issue2task` 只处理 GitHub issue 或用户直接需求。
- `codev-issue2task` 必须直接产出包含实现计划的 task 文件，不再依赖独立 `plantask` 步骤。
- `$codev-taskdev` 默认按 `tasks/` 中最小整数任务号选择待办任务。
- `codev-taskdev` 负责实现、task 文档同步和一次实现收尾精简，但不做自动验证、不归档到 `tasks/done/`。
- `codev-quickship` 负责人工验证后的 task 归档、任务相关 `docs/` / `memory/` / 必要时 `AGENTS.md` 同步，以及 commit / merge / push；它每次都要把四段版本号的最后一位加一并同步 `CHANGELOG`；若 task 明确映射 GitHub issue，则主干 push 成功后先补一条本轮工作评论，再用 `gh` 关闭对应 issue；收尾提交信息必须采用 `type: 具体工作摘要 (vX.Y.Z.W)` 形式；但不打 tag、也不做正式发布。
- 如果 `CLAUDE.md` 承载宿主代理说明或工具约束，`codev-memorize` 只能收敛 repo 事实，不能删掉这些兼容块。
- `codev-checkpoint` 是轻量 `commit/push` fallback。
- `codev-quickship` 关闭 GitHub issue 前必须先评论收尾摘要，避免只有关闭动作没有上下文。
- `codev-quickship` 的提交信息必须采用 `type: 具体工作摘要 (vX.Y.Z.W)` 形式，版本号放在最后的括号里。
- `VERSION` 采用单一四段纯数字格式；`CHANGELOG` 是与之配套的唯一版本变更记录源。

## 验证基线
- 修改安装链路后，优先跑 `./test/setup-smoke.sh`。
- 修改单个 skill 的元数据后，至少检查对应 `docs/skills/<skill>.md`、`README.md` 与受管技能列表是否同步。
- README 变更以仓库现状为准，不保留过期 skill 列表。
