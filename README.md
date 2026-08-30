# codev DevFlow

`codev` 是一套面向 Codex、Grok 和 Claude Code 的 codev skills 集合。默认工作环境是 macOS；暂不支持 Windows。

## 1. 安装

默认执行 `./setup` 时，会探测 PATH 中的 `codex`、`grok`、`claude`，只为已经安装的客户端刷新全局目录。没有对应客户端的宿主会跳过；三个都没有则安装失败。`setup` 只安装本仓库当前受管的 skills。

### 全局安装

```bash
git clone https://github.com/wmzhai/codev.git ~/codev
cd ~/codev
./setup
```

一次安装会按本机客户端链接到：

- Codex：`~/.codex/skills/`
- Grok：`~/.grok/skills/`
- Claude Code：`~/.claude/skills/`

暂不支持项目内 vendored 安装。Codex 用 `$codev-issue2task` 这类入口；Grok 和 Claude Code 用 `/codev-issue2task`。

## 2. 升级

```bash
cd ~/codev
git pull --ff-only
./setup
```

新装了某个客户端后，再跑一次 `./setup` 就会补上对应宿主。

## 3. 使用流程

下面用 Codex 的 `$` 写法；Grok 与 Claude Code 把 `$` 换成 `/`，例如 `/codev-taskdev`。

1. 先读 [docs/workflows.md](docs/workflows.md)。
2. 新仓库或记忆体系过期时，用 `$codev-memorize`。它会写齐公共 `memory/` 和三份宿主入口，换工具也能接手。
3. 需求进入任务流时，用 `$codev-issue2task` 生成 `tasks/` 下的 task plan；在工作区根目录也可以用 `$codev-issue2task <subdir>#70` 指向当前目录下某个子仓库的 GitHub issue。
4. 人工审核 task plan 后，用 `$codev-taskdev` 在 task 分支推进实现；它会在收尾自动做一次语义不变精简和默认 build / 最小编译校验，这是 quickship/checkpoint 之前唯一由 codev 自动承担的编译校验责任点。
5. 跟踪开源上游但需要保留本地运行补丁时，用 `$codev-syncpatch`；它默认不提交、不 push、不默认创建分支，会先评估本地补丁能否安全重放。
6. 只想做一次轻量 `commit / push` 时，用 `$codev-checkpoint`；其主流程与 `$codev-quickship` 一致，差异是 checkpoint 不升级 `VERSION`、不打 tag，且 checkpoint 默认同步已有 `CHANGELOG` 的未发布记录。
7. 人工验证通过后，用 `$codev-quickship` 做与 checkpoint 一致的流程，并在其上执行 `VERSION` 同步与 tag 推送；其余动作不额外区分。用户触发 quickship/checkpoint 即表示 `codev-taskdev` 收尾校验和人工验证已经完成，收口阶段不再运行 build/test/lint/typecheck 或脚本验证。如果仓库没有 task，也可以按无 task 模式收尾，但同样依赖用户触发前已完成外部确认。
8. quickship 优先遵守仓库本地版本规则；没有本地规则时接受三段或四段数字版本，并递增版本号最后一段，tag 默认使用 `v<VERSION>`。

## 4. 文档导航

- 总流程：[`docs/workflows.md`](docs/workflows.md)
- skill 索引：[`docs/skills/README.md`](docs/skills/README.md)
- Codex 入口：`AGENTS.md`
- Claude Code 入口：`CLAUDE.md`
- Grok 入口：`.grok/rules/memory.md`
- 公共记忆：`memory/`
- 底层运行规则：`skills/<name>/SKILL.md`
