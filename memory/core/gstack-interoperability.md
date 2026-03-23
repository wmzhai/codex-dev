# gstack Interoperability

只在仓库同时接入 codev 和 gstack 时读本文。

## 职责分工
- gstack：负责产品探索、计划评审、测试计划、QA、ship、repo 级人类文档同步。
- codev：负责 `tasks/`、`plantask`、`checktask`、`memorize`、`simplify`，以及把外部输入压成 repo 内任务。

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
- repo 级文档漂移默认交给 gstack `/document-release`。
- 需要 PR、review gate、覆盖率审计或自动文档同步时，优先 gstack `/ship`。
- 在 task 分支准备第一次提交或 `checkpoint` 前，可以先用 `simplify` 收窄当前 patch，再把工作区收成 clean tree。
- 只有明确需要轻量 `commit/push` 时，才用 codev `checkpoint`。

## 推荐组合流程
1. gstack `/office-hours`、`/plan-ceo-review`、`/plan-eng-review`
2. `gstack2task` 把上游工件落成 `tasks/`
3. `plantask`
4. 实现
5. `simplify` 收窄当前 patch
6. 普通 commit 或 `checkpoint`，先把工作区收成 clean tree
7. gstack `/review`、`/qa`
8. `checktask`
9. gstack `/ship`、`/document-release`

## 何时不用 gstack2task
- 需求本来就在 GitHub issue 里，直接用 `issue2task`
- 用户只是想讨论高层方向，还没准备写 `tasks/`
- `~/.gstack/projects/` 里没有与当前仓库或当前分支对应的可验证工件
