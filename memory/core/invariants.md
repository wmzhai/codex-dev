# Invariants

## 安装与发现
- `setup` 必须同时刷新 Codex（`~/.codex/skills`）和 Grok（`~/.grok/skills`）。
- Codex 必须把 `codev` 本身链接到 `~/.codex/skills/codev`。
- Grok 只链接受管 skill 目录到 `~/.grok/skills/<name>`，不把整个仓库挂到 `~/.grok/skills/codev`。
- 受管 skills 必须通过 `setup` 一次性链接，不手工散装维护。
- `test/setup-smoke.sh` 必须覆盖受管 skills 在 Codex 和 Grok 上的链接列表。

## 目录约束
- 受管 skill 不得写死某个项目的绝对路径或仓库名作为默认工作区；路径一律从当前工作目录、当前 git 根和该仓库本地规则解析。
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
- `codev-taskdev` 负责实现、task 文档同步、一次实现收尾精简和一次默认 build / 最小编译校验；这是 quickship/checkpoint 之前唯一由 codev 自动承担的编译校验责任点，但不做自动化功能验证、不归档到 `tasks/done/`。
- `codev-quickship` 与 `codev-checkpoint` 的主流程一致；quickship 在此基础上额外做 `VERSION` 同步与 tag 推送。quickship 收尾提交信息必须采用 `type: 具体工作摘要 (v<VERSION>)` 形式，checkpoint 不带版本后缀。
- `codev-memorize` 不再维护额外入口文件，记忆入口统一归并到 `AGENTS.md + memory/`。
- `codev-checkpoint` 是轻量 `commit/push` fallback；若当前可定位任务，会补齐任务记录并归档到 `tasks/done/`。其流程与 `codev-quickship` 一致，但不处理版本和 tag。
- 用户触发 quickship/checkpoint 即表示 `codev-taskdev` 收尾校验和人工验证已经完成；无 task 模式也依赖用户触发前已完成外部确认，收口 skill 不运行 build/test/lint/typecheck 或脚本验证。
- `codev-syncpatch` 默认不提交、不 push、不默认创建分支；在同步 upstream 前必须先备份本地 diff 并判断是否能高置信度按原意重放本地补丁，不能确认时必须先问用户。
- `codev-quickship` 关闭 GitHub issue 前必须先评论收尾摘要，避免只有关闭动作没有上下文。
- `codev-quickship` 的提交信息必须采用 `type: 具体工作摘要 (v<VERSION>)` 形式，版本号放在最后的括号里。
- `VERSION` 优先按仓库本地规则解析；没有本地规则时默认接受三段或四段数字版本，并递增最后一段。

## 验证基线
- 修改安装链路后，优先跑 `./test/setup-smoke.sh`。
- 修改单个 skill 的元数据后，至少检查对应 `docs/skills/<skill>.md`、`README.md` 与受管技能列表是否同步。
- README 变更以仓库现状为准，不保留过期 skill 列表。
