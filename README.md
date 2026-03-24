# Codev Skills

`codev` 是一组给 Codex 用的开发流程 skills。它和 `gstack` 配合时，职责边界很明确：

- `codev` 负责把外部输入压成 repo 内 `tasks/` 与可审核的执行 plan，并承接 task 分支内的执行技能。
- `gstack` 负责上游规划、深度 review、QA 和正式发布流程。

## 1. 安装

### 先安装 gstack

```bash
git clone https://github.com/garrytan/gstack.git ~/gstack
cd ~/gstack
./setup --host codex
```

### 再安装 codev

```bash
git clone https://github.com/wmzhai/codev.git ~/codev
cd ~/codev
./setup
```

## 2. 高层摘要

- 半自动路径：`$office-hours -> $autoplan -> $gstack2task/$issue2task -> 审核 task plan -> $autodev -> 人工确认 -> $automerge`
- 人工路径：按规划、任务、实现、验证、发布逐步运行各个 skill，由人类在关键节点做深度判断。
- repo 内的 `tasks/` 是 codev 的执行单元；任务文件本身同时承载需求、实现计划与验收基线；`~/.gstack/projects/` 是 gstack 的上游工件目录。

## 3. 详细文档

- [半自动开发流程](docs/semi-auto-workflow.md)
- [人工深度参与流程](docs/manual-workflow.md)
- [Skill 详细手册](docs/skill-reference.md)
