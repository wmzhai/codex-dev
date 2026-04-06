# codev DevFlow

`codev` 是一套面向 Claude / Codex 的 codev skills 集合。默认工作环境是 macOS；暂不支持 Windows。

## 1. 安装

默认执行 `./setup` 时，会同时安装到 Claude 和 Codex。只有显式传 `--host` 时，才只安装单个宿主。`setup` 只安装本仓库当前受管的 skills。

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

当前只支持全局安装到 `~/.codex/skills/` 和/或 `~/.claude/skills/`。暂不支持项目内 vendored 安装。

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

## 3. 使用流程

1. 先读 [docs/workflows.md](docs/workflows.md)。
2. 新仓库或记忆体系过期时，用 `$codev-memorize`。
3. 需求进入任务流时，用 `$codev-issue2task` 生成 `tasks/` 下的 task plan。
4. 人工审核 task plan 后，用 `$codev-taskdev` 在 task 分支推进实现。
5. 只想做一次轻量 `commit / push` 时，用 `$codev-checkpoint`；checkpoint 不再默认同步根目录 `VERSION` 与 `CHANGELOG`。
6. 人工验证通过后，用 `$codev-quickship` 做归档、主动 build、版本同步和主干收尾；如果仓库没有 task，也可以按无 task 模式收尾，但要在 `CHANGELOG` 记录本轮改动摘要；quickship 默认递增 `VERSION` 的补丁位。

## 4. 文档导航

- 总流程：[`docs/workflows.md`](docs/workflows.md)
- skill 索引：[`docs/skills/README.md`](docs/skills/README.md)
- Codex 入口：`AGENTS.md`
- Claude 入口：`CLAUDE.md`
- 底层运行规则：`skills/<name>/SKILL.md`
