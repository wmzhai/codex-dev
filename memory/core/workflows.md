# Workflows

## 新会话默认动作
1. 读 `AGENTS.md`
2. 读 `docs/workflows/README.md`
3. 读 `memory/core/symptom-routing.md`
4. 如果仓库同时用 gstack，再读 `memory/core/gstack-interoperability.md`
5. 按问题进入 `docs/skills/<skill>.md`
6. 需要运行规则时，再回到对应 skill 的 `SKILL.md`
7. 用 `rg` 定位源码或脚本，再开始改动

## 与 gstack 配合
1. gstack `$office-hours`、`$plan-ceo-review`、`$plan-eng-review` 先把上游设计、交接和测试计划写到 `~/.gstack/projects/`
2. GitHub issue 或直接需求走 `codev-issue2task`；gstack 工件走 `codev-gstack2task`
3. `codev-issue2task` 与 `codev-gstack2task` 都要结合代码直接写出带实现计划的 `tasks/Txx-*.md`
4. 用户先审核 task 文件中的 plan，再决定进入 `$codev-taskdev` 或 `codev-autodev`
5. `$codev-taskdev` 负责按已审核 plan 选择任务、实施代码并做最小本地验证
6. 默认更安全的自动闭环是 `codev-autodev`：它内含 `$codev-taskdev` 阶段，再继续推进实现、审查、测试、分支部署，并持续更新对应 `tasks/Txx-*.md`
7. 用户确认当前结果后，小改动可用 `codev-quickship` 快速直推主干；在分支上就 merge，在主干上就 commit + push；需要正式收尾时再用 `codev-automerge`
8. 如果不用 `codev-autodev` / `codev-automerge` / `codev-quickship`，手动路径仍可继续使用 `codev-simplify`、`codev-checkpoint`、gstack `$review`、`$qa`、`$ship`、`$document-release` 与 `$land-and-deploy`
9. `codev-checktask` 仍负责手动验收、更新 `memory/` 和任务直接相关的局部 `docs/`
10. `codev-checkpoint` 只保留给显式的轻量 `commit/push` 场景

## 新增 skill
1. 创建 skill 目录和 `SKILL.md`
2. 补 `agents/openai.yaml`
3. 新增 `docs/skills/<skill>.md`
4. 更新 `README.md` 的 Skills 一览和说明
5. 更新 `setup`
6. 更新 `test/setup-smoke.sh`
7. 跑 smoke test

## 修改安装链路
1. 改 `setup`
2. 同步 `test/setup-smoke.sh`
3. 更新 `README.md`
4. 必要时更新 `docs/workflows/README.md`
5. 验证干净 HOME、幂等性和冲突处理

## 修改既有 skill
1. 先改对应 `SKILL.md`
2. 同步 `docs/skills/<skill>.md`
3. 必要时同步 `agents/openai.yaml`
4. 如果影响触发、安装或导航，再改 `README.md`、`docs/workflows/README.md`、`setup` 或 smoke test
5. 如果影响 codev 与 gstack 的职责边界，再改 `memory/core/gstack-interoperability.md` 和 `AGENTS.md`

## 维护原则
- 先让记忆系统追上真实代码，再考虑增加解释。
- 发现过期内容直接删，不保留“以后也许有用”的历史负担。
