# Workflows

## 新会话默认动作
1. 读当前宿主入口：`AGENTS.md`、`CLAUDE.md` 或 `.grok/rules/memory.md`
2. 读 `memory/core/invariants.md`
3. 读 `docs/workflows.md`
4. 读 `memory/core/symptom-routing.md`
5. 按问题进入 `docs/skills/<skill>.md`
6. 需要运行规则时，再回到对应 skill 的 `SKILL.md`
7. 用 `rg` 定位源码或脚本，再开始改动

## 默认主线
1. GitHub issue 或直接需求走 `codev-issue2task`
2. 任务入口要结合代码直接写出带实现计划的 `tasks/Txx-*.md`
3. 用户先审核 task 文件中的 plan，再进入当前宿主对应的 `codev-taskdev` 入口（Codex：`$codev-taskdev`，Grok：`/codev-taskdev`，Claude Code：`/codev-taskdev`）
4. `codev-taskdev` 负责按已审核 plan 选择任务、实施代码、同步任务文档，并在实现收尾自动做一次语义不变精简和一次默认 build / 最小编译校验；这是 quickship/checkpoint 前唯一由 codev 自动承担的编译校验责任点
5. 功能默认由人工验证；人工验证通过后，再用 `codev-quickship` 完成 task 归档、任务相关文档同步、版本工件同步，以及 commit / merge / push / tag；用户触发即表示 taskdev 收尾校验和人工验证已完成，无 task 模式也依赖用户外部确认
6. `codev-checkpoint` 用于轻量 `commit/push` 场景，并默认不同步版本工件；checkpoint 与 quickship 收口阶段都不运行 build/test/lint/typecheck 或脚本验证
7. `codev-syncpatch` 用于同步开源 upstream 并保留本地运行补丁；它独立于 task 主线，默认不提交、不 push、不默认创建分支

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
4. 必要时更新 `docs/workflows.md` 与三份宿主入口
5. 验证探测、跳过、干净 HOME、幂等性和冲突处理

## 修改既有 skill
1. 先改对应 `SKILL.md`
2. 同步 `docs/skills/<skill>.md`
3. 必要时同步 `agents/openai.yaml`
4. 如果影响触发、安装或导航，再改 `README.md`、`docs/workflows.md`、`setup` 或 smoke test
5. 如果改了面向用户的 skill 调用提示，跑 `./test/skill-invocation-prefix.sh`

## 维护原则
- 先让记忆系统追上真实代码，再考虑增加解释。
- 发现过期内容直接删，不保留“以后也许有用”的历史负担。
- 谁初始化项目，另外两家都要能从同一份 `memory/` 接手。
