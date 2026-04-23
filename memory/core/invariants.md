# Invariants

## 安装与发现
- `setup` 必须把 `codev` 本身链接到 `~/.codex/skills/codev`；默认无参时安装 Codex，显式 `--host` 时只支持 codex 目标。
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
- `codev-taskdev` 负责实现、task 文档同步、一次实现收尾精简和一次默认 build / 最小编译校验，但不做自动化功能验证、不归档到 `tasks/done/`。
- `codev-quickship` 负责人工验证后的 task 归档、任务相关 `docs/` / `memory/` / 必要时 `AGENTS.md` 同步，以及 commit / merge / push；有 task 时默认沿用 `codev-taskdev` 收尾阶段已完成的默认 build / 最小编译校验，只有无 task 或用户明确要求复验时才在 quickship 内补跑；若 task 明确映射 GitHub issue，则主干 push 成功后先补一条本轮工作评论，再用 `gh` 关闭对应 issue；收尾提交信息必须采用 `type: 具体工作摘要 (vX.Y.Z)` 形式；但不打 tag、也不做正式发布。
- `codev-memorize` 不再维护额外入口文件，记忆入口统一归并到 `AGENTS.md + memory/`。
- `codev-checkpoint` 是轻量 `commit/push` fallback。
- `codev-syncpatch` 默认不提交、不 push、不默认创建分支；在同步 upstream 前必须先备份本地 diff 并判断是否能高置信度按原意重放本地补丁，不能确认时必须先问用户。
- `codev-quickship` 关闭 GitHub issue 前必须先评论收尾摘要，避免只有关闭动作没有上下文。
- `codev-quickship` 的提交信息必须采用 `type: 具体工作摘要 (vX.Y.Z)` 形式，版本号放在最后的括号里。
- `VERSION` 默认采用单一 `X.Y.Z` 格式；需要同步版本工件时，若格式不符必须停止并明确说明原因。

## 验证基线
- 修改安装链路后，优先跑 `./test/setup-smoke.sh`。
- 修改单个 skill 的元数据后，至少检查对应 `docs/skills/<skill>.md`、`README.md` 与受管技能列表是否同步。
- README 变更以仓库现状为准，不保留过期 skill 列表。
