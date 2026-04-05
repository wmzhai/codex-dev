# `$codev-memorize`

Source: `codev`

## Purpose

为当前仓库建立或刷新以 `AGENTS.md + memory/` 为核心、兼容 `CLAUDE.md` 入口的记忆体系，让新 session 知道先读什么、规则从哪里继承、流程文档去哪里找。

## Preconditions

- 当前目录是可读仓库根目录。
- 允许更新 `AGENTS.md`、`memory/` 和相关导航文档。
- 不要求 clean tree，但最好知道现有文档是否已漂移。

## Inputs / Source Of Truth

- 仓库根目录结构
- `README.md`
- 如果是全新项目，则把用户明确提供的项目目标、边界和约定一起视为初始输入
- 现有 `AGENTS.md`
- `memory/`
- 如存在则读取 `CLAUDE.md`
- 主要入口文件、配置文件、脚本与目录分层

## Produces / Writes

- `AGENTS.md`
- `memory/README.md`
- `memory/core/*`
- 必要时更新文档导航，例如 `README.md` 或 `docs/workflows.md`

## Execution Flow

1. 扫描仓库入口、结构信号和已有文档，确认当前 repo 的真实边界。
2. 如果这是全新项目、代码与目录尚未长成，则用 `README.md` 和用户明确输入的项目信息先建立最小记忆骨架。
3. 提炼高优先级规则，收敛到 `AGENTS.md`，保持短而硬。
4. 重写或刷新 `memory/README.md`，把热路径、冷路径和默认读法说清楚。
5. 更新 `memory/core/` 中的系统图、工作流、稳定约束和仓库职责边界。
6. 若 `CLAUDE.md` 存在，只提取 repo 事实进入 `AGENTS.md`，保留宿主代理兼容块。
7. 删除已经失效的旧路由、旧目录名和过期流程说明。

## Stops / Failure Modes

- 无法判断仓库根目录或主要结构。
- 关键事实只能靠猜测，无法从代码或现有文档确认。
- 全新项目场景下，用户输入本身仍然过于模糊，无法形成可落地的最小记忆骨架。
- `CLAUDE.md` 中宿主兼容块与 repo 事实冲突，且无法安全合并。

## Next Recommended Steps

- 需要总流程时：读 `docs/workflows.md`
- 需要具体 skill：读 `docs/skills/README.md`
- 要进入任务流：继续 `$codev-issue2task`
