# System Map

只在仓库边界不清时读本文。

## 分层
- `README.md`：面向用户的总说明、安装方式、调用示例、skills 列表
- `docs/workflows.md`：从开始到结束的唯一工作流导航
- `docs/skills/*.md`：当前受管 codev skills 的详细手册
- `setup`：按 `--host claude|codex` 安装当前仓库到对应的全局 skills 目录，并链接受管 skills；默认无参时同时安装 Claude 与 Codex
- `test/setup-smoke.sh`：验证安装、幂等性和冲突处理
- `skills/codev-memorize/`：为项目建立或刷新以 `AGENTS.md + memory/` 为核心、兼容 `CLAUDE.md` 的记忆体系
- `skills/codev-issue2task/`：把 issue 或直接需求收敛成带实现计划的任务文件
- `skills/codev-taskdev/`：按已审核 task plan 选择目标任务、实施代码、同步任务文档，并在实现收尾自动做一次语义不变精简和一次默认 build / 最小编译校验
- `skills/codev-quickship/`：在用户完成人工验证后归档 task、同步任务相关 `docs/` / `memory/` / 必要时 `AGENTS.md`；有 task 时沿用 `codev-taskdev` 已完成的默认 build，无 task 时补跑，再同步根目录 `VERSION` 与 `CHANGELOG`，然后提交、合并、推送主干
- `skills/codev-simplify/`：语义不变精简 diff
- `skills/codev-checkpoint/`：轻量提交、推送 fallback
- `skills/codev-syncpatch/`：同步开源 upstream 并按原意重放本地运行补丁；默认不提交、不推送、不默认创建分支
- `VERSION` / `CHANGELOG`：仓库的版本工件，供 `codev-checkpoint` 与 `codev-quickship` 读取和最小同步

## 维护边界
- `SKILL.md` 是每个 skill 的主说明和工作流。
- `agents/openai.yaml` 只放 UI 元数据和调用策略。
- `README.md` 只放仓库级说明与技能导航。
- `docs/workflows.md` 保留唯一工作流导航。
- `docs/skills/<skill>.md` 是对外的 skill 详细手册。
- `setup` 和 `test/setup-smoke.sh` 共同定义“哪些 skill 算受管”。
- `codev-issue2task` 是唯一任务入口：处理 GitHub issue 或直接需求，并直接产出可执行 task plan。
- `codev-taskdev` 是 task 分支实现层；`codev-quickship` 负责人工验证后的收尾。

## 常见改动落点
- 新增 skill：新增 `skills/<name>/` 目录，同时同步 `setup`、`test/setup-smoke.sh`、`README.md`
- 新增 skill 文档：同步新增 `docs/skills/<name>.md`
- 修改 skill 触发或行为：改对应 `SKILL.md` 和 `agents/openai.yaml`
- 修改安装链路：改 `setup` 和 `test/setup-smoke.sh`
- 修改外部说明：改 `README.md`、`docs/workflows.md`、`docs/skills/*.md`
