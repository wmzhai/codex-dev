# Symptom Routing

默认只读本文和一个相关 skill 文档；不要先通读整个仓库。

## 想知道这个仓库是干什么的
- `README.md`
- `AGENTS.md`
- `docs/workflows.md`

## 想新增或修改一个 skill
- 对应 skill 的 `SKILL.md`
- `docs/skills/<skill>.md`
- `agents/openai.yaml`
- `README.md`
- `setup`
- `test/setup-smoke.sh`

## 想确认安装是否正确
- `setup`
- `test/setup-smoke.sh`

## 想知道该用哪个 skill
- 先看 `docs/workflows.md`
- 再看 `docs/skills/README.md`
- 最后看对应 skill 的 `SKILL.md`

## 想给项目建立 AGENTS / memory 记忆入口
- `docs/skills/codev-memorize.md`
- `skills/codev-memorize/SKILL.md`
- 当前仓库的 `README.md`
- 根目录 `AGENTS.md`

## 想走任务流
- `docs/workflows.md`
- `docs/skills/codev-issue2task.md`
- `docs/skills/codev-taskdev.md`
- `docs/skills/codev-quickship.md`

## 想做提交或收尾
- `docs/skills/codev-checkpoint.md`
- `docs/skills/codev-quickship.md`
- `skills/codev-checkpoint/SKILL.md`
- `skills/codev-quickship/SKILL.md`

## 想同步开源上游且保留本地补丁
- `docs/skills/codev-syncpatch.md`
- `skills/codev-syncpatch/SKILL.md`

## 想做语义不变精简
- `docs/skills/codev-simplify.md`
- `skills/codev-simplify/SKILL.md`
