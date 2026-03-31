# codev DevFlow

`codev` 是一套面向 Claude / Codex 的开发工作流整合库，默认工作环境是 macOS，不支持 Windows 平台。

## 1. 安装

默认 `./setup` 会同时安装到 Claude 和 Codex；只有显式传 `--host` 时才只安装单个宿主。

### Claude + Codex 全局安装

```bash
git clone https://github.com/wmzhai/codev.git ~/codev
cd ~/codev
./setup
```

### 仅 Codex 全局安装

```bash
git clone https://github.com/wmzhai/codev.git ~/codev
cd ~/codev
./setup --host codex
```

### 仅 Claude 全局安装

```bash
git clone https://github.com/wmzhai/codev.git ~/codev
cd ~/codev
./setup --host claude
```

当前只支持全局安装到 `~/.codex/skills/` 和/或 `~/.claude/skills/`，暂不支持项目内 `.agents/skills/` / `.claude/skills/` vendored 安装。

## 2. 升级

### Claude + Codex

```bash
cd ~/codev
git pull --ff-only
./setup
```

### 仅 Codex

```bash
cd ~/codev
git pull --ff-only
./setup --host codex
```

### 仅 Claude

```bash
cd ~/codev
git pull --ff-only
./setup --host claude
```

## 3. 快速入门

- 使用本项目时，优先按 [docs/workflows/README.md](docs/workflows/README.md) 的流程走。
- Claude 入口见根目录 `CLAUDE.md`；Codex 入口见 `AGENTS.md`。
- 某一步涉及哪个 skill、不清楚怎么用时，去看 [docs/skills/README.md](docs/skills/README.md) 和对应的 `docs/skills/<skill>.md`。
- 如果要看更底层的运行规则，再去看 `skills/<name>/SKILL.md`。

## 4. 其他使用方式

1. 先读 [docs/workflows/README.md](docs/workflows/README.md)，按总流程图决定自己现在处在哪个阶段。
2. 如果是新仓库或记忆体系过期，先用 `$codev-memorize`。
3. 如果需求来自 gstack 工件，用 `$codev-gstack2task`；如果需求来自 issue 或直接需求，用 `$codev-issue2task`。`$codev-gstack2task` 默认先产出一个总 task，只有判断必须拆成多个时才会先向用户确认拆分清单；`$codev-issue2task` 会先结合代码和 issue 做需求理解与中文讨论，只有在用户确认关键细节后才写入 task 文件，且显式传多个 issue 编号时支持逗号或空格分隔，默认合并成一个总 task。
4. 审核生成出来的 task plan；对 `$codev-issue2task` 来说，先完成需求确认对话，再审核落盘后的 task。
5. 审核通过后，用 `$codev-taskdev` 在 task 分支上推进实现；它会持续更新 task 文档，并在实现收尾自动做一次语义不变精简。若只需要中途做一次轻量提交，可用 `$codev-checkpoint`；checkpoint 默认会同步根目录 `VERSION` 与 `CHANGELOG`，未显式指定目标版本时默认把第 4 位加一。
6. 功能由人工验证通过后，用 `$codev-quickship` 完成 `tasks/done/` 归档、任务相关 `docs/` / `memory/` / 必要时 `AGENTS.md` 同步，以及同步根目录 `VERSION` 与 `CHANGELOG`；如果未显式指定目标版本，quickship 默认把最后一位加一，再执行 commit / merge / push；提交信息要使用 `type: 具体工作摘要 (vX.Y.Z.W)` 形式；如果 task 明确源自 GitHub issue，还要在主干 push 成功后先补一条该轮工作的评论，再通过 `gh` 关闭对应 issue；如果仓库需要正式发布链路，走 `$ship -> $land-and-deploy -> $document-release`。

## 5. 相关文档

- [总流程图与总导航](docs/workflows/README.md)
- [旁支流程目录](docs/workflows/)
- [所有 skill 详细手册索引](docs/skills/README.md)
