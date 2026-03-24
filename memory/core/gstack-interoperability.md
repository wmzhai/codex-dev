# gstack Interoperability

只在仓库同时接入 codev 和 gstack 时读本文。

## 职责分工
- gstack：负责产品探索、计划评审、测试计划、QA、ship、repo 级人类文档同步。
- codev：负责 `tasks/`、任务内实现计划、`taskdev`、`checktask`、`memorize`、`simplify`，以及把外部输入压成 repo 内任务；`autodev` / `automerge` 负责把下游固定流程收口成更安全的自动化编排。

## 两条任务入口
- `issue2task`：输入是 GitHub issue 或用户直接需求。
- `gstack2task`：输入是 `~/.gstack/projects/` 下的 design doc、implementation handoff、test plan、CEO handoff 等工件。
- 两者都写入 `tasks/`，但不要让一个 skill 去兼做另一个 skill 的输入解析。

## Source Of Truth
- 上游产品与工程意图：`~/.gstack/projects/<slug>/`
- repo 内执行单元：`tasks/`
- 机器记忆：`AGENTS.md` + `memory/`
- repo 级人类文档：`README.md`、`CHANGELOG`、`CLAUDE.md`、`CONTRIBUTING.md`、`TODOS`

## 不冲突规则
- `memorize` 可以把 `CLAUDE.md` 里的 repo 事实并入 `AGENTS.md`，但必须保留宿主代理或 gstack 仍然需要的兼容块。
- `checktask` 默认只更新 `memory/` 和任务直接相关的局部 `docs/`，不要顺手改 repo 级文档。
- repo 级文档漂移默认交给 gstack `$document-release`。
- 需要 PR、review gate、覆盖率审计或自动文档同步时，优先 gstack `$ship`。
- `$taskdev` 只负责按已审核 plan 实施代码和最小本地验证；不要把它扩成 QA、部署或发布入口。
- 在 task 分支准备第一次提交或 `checkpoint` 前，可以先用 `simplify` 收窄当前 patch，再把工作区收成 clean tree。
- 只有明确需要轻量 `commit/push` 时，才用 codev `checkpoint`。
- `autodev` 内含 `$taskdev` 的任务选择、plan 校准和编码阶段；如果已经决定走 `autodev`，不需要先显式运行 `$taskdev`。
- `autodev` 可以复用 gstack 的 `review`、`qa` 或仓库现有部署能力，但默认停在 task 分支的“已部署待人工确认”，不 merge 主干，也不打版本号。
- `automerge` 才负责进入正式发布路径；如兼容，优先复用 gstack `$ship`、`$land-and-deploy` 与 `$document-release`。
- `autodev` 的 task 文档维护是持续行为，不依赖 `checktask` 的最后一次同步。

## 推荐组合流程
1. gstack `$office-hours`、`$plan-ceo-review`、`$plan-eng-review`
2. `gstack2task` 把上游工件落成包含实现计划的 `tasks/`
3. 用户先审核 task 文件中的实现计划
4. 手动路径用 `$taskdev` 先把已审核 plan 落成代码；半自动路径则直接交给 `autodev`
5. `autodev` 在 task 分支上按已审核 plan 推进实现、验证、分支部署，并持续更新任务文档
6. 用户确认部署结果
7. `automerge` 合并主干、处理版本号、正式发布并归档任务

## 手动路径仍然可用
1. `issue2task` 或 `gstack2task`
2. 审核 task 文件中的实现计划
3. `$taskdev`
4. `simplify` 收窄当前 patch
5. 普通 commit 或 `checkpoint`，先把工作区收成 clean tree
6. gstack `$review`、`$qa`
7. `checktask`
8. gstack `$ship`
9. 视需要补 gstack `$document-release`
10. gstack `$land-and-deploy`

## 何时不用 gstack2task
- 需求本来就在 GitHub issue 里，直接用 `issue2task`
- 用户只是想讨论高层方向，还没准备写 `tasks/`
- `~/.gstack/projects/` 里没有与当前仓库或当前分支对应的可验证工件
