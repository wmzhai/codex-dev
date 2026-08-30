# Invariants

## 安装与发现
- `setup` 无参执行，按 PATH 中是否存在 `codex`、`grok`、`claude` 决定刷新哪些全局 skills。
- 探测只认 `command -v`，不把 `~/.codex`、`~/.grok`、`~/.claude` 目录存在当成已安装，也不把 macOS 自带的 `gpt` 当成 Codex。
- 有对应客户端则幂等安装或更新；没有则打印跳过，且不创建该宿主的 skills 目录。
- 三个客户端都没有则失败，提示需要先装 `codex`、`grok` 或 `claude`。
- Codex 必须把 `codev` 本身链接到 `~/.codex/skills/codev`，再把受管 skill 链成 `codev/skills/<name>`。
- Grok 只链接受管 skill 目录到 `~/.grok/skills/<name>`，不把整个仓库挂到 `~/.grok/skills/codev`。
- Claude Code 与 Grok 相同，目标为 `~/.claude/skills/<name>`；若存在指向本仓库的遗留 `~/.claude/skills/codev` 链接则删除。
- 受管 skills 必须通过 `setup` 一次性链接，不手工散装维护。
- `test/setup-smoke.sh` 必须覆盖客户端探测、跳过、混装、冲突处理和受管 skills 链接列表。
- 不恢复 `--host`，不支持项目内 vendored 安装，不写 `~/.agents/skills`。

## 目录约束
- 受管 skill 不得写死某个项目的绝对路径或仓库名作为默认工作区；路径一律从当前工作目录、当前 git 根和该仓库本地规则解析。
- `skills/<name>/` 目录名必须和 `SKILL.md` 的 `name` 一致。
- `SKILL.md` 负责工作流；`agents/openai.yaml` 负责 Codex UI 元数据。
- `README.md` 是仓库级导航，不替代 `SKILL.md`。
- `docs/workflows.md` 必须保留唯一工作流导航。
- `docs/skills/<skill>.md` 必须覆盖对应 skill 的详细手册。
- 公共事实只写在 `memory/`。
- Codex 入口是 `AGENTS.md`，Claude Code 入口是 `CLAUDE.md`，Grok 入口是 `.grok/rules/memory.md`。三份入口只放宿主守卫、一两句硬规则和专用前缀/路径，不复制公共长文。

## 内容约束
- `SKILL.md` 的 `description` 必须同时说明“做什么”和“什么时候用”。
- 新增 skill 时，README、setup、smoke test 必须同步。
- 本仓库是 codev skills 的集合，不是应用业务仓库。
- `codev-memorize` 的职责是建立或刷新 `memory/` 以及三份宿主入口，不负责业务逻辑。
- 无论当前会话是 Codex、Grok 还是 Claude Code，`codev-memorize` 都必须一次写齐 `memory/`、`AGENTS.md`、`CLAUDE.md` 和 `.grok/rules/memory.md`，保证换工具也能接手。
- 已有入口中的宿主专用段落必须保留；只把与仓库事实重复的正文迁到 `memory/`，不要整文件覆盖成另一份记忆百科。
- `codev-issue2task` 只处理 GitHub issue 或用户直接需求。
- `codev-issue2task` 必须直接产出包含实现计划的 task 文件，不再依赖独立 `plantask` 步骤。
- `codev-taskdev` 默认按 `tasks/` 中最小整数任务号选择待办任务。
- `codev-taskdev` 负责从 `tasks/` 中选择目标 plan，按已审核 `Implementation Plan` 实施代码、持续同步任务文档，并在实现收尾做一次语义不变精简和一次默认 build / 最小编译校验；这是 quickship/checkpoint 之前唯一由 codev 自动承担的编译校验责任点，但不做自动化功能验证、不归档到 `tasks/done/`。
- 面向用户写出 skill 调用时：对话里按当前宿主写，Codex 用 `$name`，Grok 用 `/name`，Claude Code 用 `/name`；落盘的 `memory/`、`docs/`、`README.md` 必须同时列出三家，不能把 Codex 的 `$` 写成唯一模板。
- `codev-quickship` 与 `codev-checkpoint` 的主流程一致；quickship 额外做 `VERSION` 同步与 tag 推送，收尾提交信息必须采用 `type: 具体工作摘要 (v<VERSION>)` 形式，版本号放在最后的括号里。checkpoint 不带版本后缀。
- `codev-checkpoint` 是轻量 `commit/push` fallback；若当前可定位任务，会补齐任务记录并归档到 `tasks/done/`。默认同步已有 `CHANGELOG` 的未发布记录，不修改根目录 `VERSION`、不创建或推送 tag。
- 若仓库里没有可定位 task，则 quickship 按无 task 模式收尾，但同样依赖用户触发前已完成外部确认。
- 用户触发 quickship/checkpoint 即表示 `codev-taskdev` 收尾校验和人工验证已经完成；无 task 模式也依赖用户触发前已完成外部确认，收口 skill 不运行 build/test/lint/typecheck 或脚本验证。
- `codev-syncpatch` 默认不提交、不 push、不默认创建分支；在同步 upstream 前必须先备份本地 diff 并判断是否能高置信度按原意重放本地补丁，不能确认时必须先问用户。
- `codev-quickship` 关闭 GitHub issue 前必须先评论收尾摘要，避免只有关闭动作没有上下文。
- `VERSION` 优先按仓库本地规则解析；没有本地规则时默认接受三段或四段数字版本，并递增版本号最后一段，tag 默认使用 `v<VERSION>`。

## 验证基线
- 修改安装链路后，优先跑 `./test/setup-smoke.sh`。
- 修改单个 skill 的元数据后，至少检查对应 `docs/skills/<skill>.md`、`README.md` 与受管技能列表是否同步。
- 修改面向用户的 skill 调用前缀后，优先跑 `./test/skill-invocation-prefix.sh`。
- README 变更以仓库现状为准，不保留过期 skill 列表。
