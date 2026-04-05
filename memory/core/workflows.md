# Workflows

## 新会话默认动作
1. 读 `AGENTS.md`
2. 读 `docs/workflows.md`
3. 读 `memory/core/symptom-routing.md`
4. 按问题进入 `docs/skills/<skill>.md`
5. 需要运行规则时，再回到对应 skill 的 `SKILL.md`
6. 用 `rg` 定位源码或脚本，再开始改动

## 默认主线
1. GitHub issue 或直接需求走 `codev-issue2task`
2. 任务入口要结合代码直接写出带实现计划的 `tasks/Txx-*.md`
3. 用户先审核 task 文件中的 plan，再进入 `$codev-taskdev`
4. `$codev-taskdev` 负责按已审核 plan 选择任务、实施代码、同步任务文档，并在实现收尾自动做一次语义不变精简
5. 功能默认由人工验证；人工验证通过后，再用 `codev-quickship` 完成 task 归档、任务相关文档同步、版本工件同步，以及 commit / merge / push
6. `codev-checkpoint` 用于轻量 `commit/push` 场景，并默认同步版本工件

## 新增 skill
1. 创建 skill 目录和 `SKILL.md`
2. 补 `agents/openai.yaml`
3. 新增 `docs/skills/<skill>.md`
4. 更新 `README.md`
5. 更新 `setup`
6. 更新 `test/setup-smoke.sh`
7. 跑 smoke test

## 修改安装链路
1. 改 `setup`
2. 同步 `test/setup-smoke.sh`
3. 更新 `README.md`
4. 必要时更新 `docs/workflows.md`
5. 验证干净 HOME、幂等性和冲突处理

## 修改既有 skill
1. 先改对应 `SKILL.md`
2. 同步 `docs/skills/<skill>.md`
3. 必要时同步 `agents/openai.yaml`
4. 如果影响触发、安装或导航，再改 `README.md`、`docs/workflows.md`、`setup` 或 smoke test

## 维护原则
- 先让记忆系统追上真实代码，再考虑增加解释。
- 发现过期内容直接删，不保留“以后也许有用”的历史负担。
