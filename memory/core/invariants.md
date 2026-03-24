# Invariants

## 安装与发现
- `setup` 必须把 `codev` 本身链接到 `~/.codex/skills/codev`。
- 受管 skills 必须通过 `setup` 一次性链接，不手工散装维护。
- `test/setup-smoke.sh` 必须覆盖受管 skills 的链接列表。
- `gstack2task` 属于受管 skills，新增后必须和其它 skills 一样进入 `setup` 与 smoke test。

## 目录约束
- `skills/<name>/` 目录名必须和 `SKILL.md` 的 `name` 一致。
- `SKILL.md` 负责工作流；`agents/openai.yaml` 负责 UI 元数据。
- `README.md` 是仓库级导航，不替代 `SKILL.md`。

## 内容约束
- `SKILL.md` 的 `description` 必须同时说明“做什么”和“什么时候用”。
- 新增 skill 时，README、setup、smoke test 必须同步。
- `memorize` 的职责是建立或刷新 `AGENTS.md` 与 `memory/`，不负责业务逻辑。
- `issue2task` 只处理 GitHub issue 或用户直接需求，不读取 `~/.gstack/projects/`。
- `gstack2task` 只处理 `~/.gstack/projects/` 下的 gstack 工件，不查询 GitHub issue。
- `issue2task` 与 `gstack2task` 都必须直接产出包含实现计划的 task 文件，不再依赖独立 `plantask` 步骤。
- `$taskdev` 与 `autodev` 默认都按 `tasks/` 中最小整数任务号选择待办任务；`autodev` 内含 `$taskdev` 阶段，不要求显式先运行一次 `$taskdev`。
- 如果 `CLAUDE.md` 承载宿主代理说明、gstack section 或工具约束，`memorize` 只能收敛 repo 事实，不能删掉这些兼容块。
- `checktask` 可以更新 `memory/` 与任务直接相关的局部 `docs/`，但默认不改 `README.md`、`CHANGELOG`、`VERSION`、`CLAUDE.md`、`CONTRIBUTING.md`、`TODOS` 这类 repo 级文档。
- `checkpoint` 是轻量 `commit/push` fallback；仓库接入 gstack 时，默认发布入口应是 gstack `$ship`。

## 验证基线
- 修改安装链路后，优先跑 `./test/setup-smoke.sh`。
- 修改单个 skill 的元数据后，优先跑 `quick_validate.py`。
- README 变更以仓库现状为准，不保留过期 skill 列表。
