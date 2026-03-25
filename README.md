# Codex DevFlow

`codev` 基于一套基于Codex的自用开发工作流整合库, 默认工作环境是macOS,不支持windows平台.

## 1. 安装

```bash
git clone https://github.com/wmzhai/codev.git ~/codev
cd ~/codev
./setup
```

## 2. 升级

```bash
cd ~/codev
git pull --ff-only
./setup
```

## 3. 快速入门

- 使用本项目时，优先按 [docs/workflows/README.md](docs/workflows/README.md) 的流程走。
- 某一步涉及哪个 skill、不清楚怎么用时，去看 [docs/skills/README.md](docs/skills/README.md) 和对应的 `docs/skills/<skill>.md`。
- 如果要看更底层的运行规则，再去看 `skills/<name>/SKILL.md`。

## 4. 其他使用方式

1. 先读 [docs/workflows/README.md](docs/workflows/README.md)，按总流程图决定自己现在处在哪个阶段。
2. 如果是新仓库或记忆体系过期，先用 `$codev-memorize`。
3. 如果需求来自 gstack 工件，用 `$codev-gstack2task`；如果需求来自 issue 或直接需求，用 `$codev-issue2task`。`$codev-gstack2task` 默认先产出一个总 task，只有判断必须拆成多个时才会先向用户确认拆分清单；`$codev-issue2task` 显式传多个 issue 编号时支持逗号或空格分隔，默认合并成一个总 task。
4. 审核生成出来的 task plan。
5. 想手动推进实现，用 `$codev-taskdev`；想自动推进到“已部署待人工确认”，用 `$codev-autodev`。
6. 小改动想直接直推主干，用 `$codev-quickship`：在分支上就先 merge 到主干，在主干上就直接 commit + push；需要正式收尾时，走 `$ship -> $land-and-deploy`，或在自动链路里走 `$codev-automerge`。

## 5. 相关文档

- [总流程图与总导航](docs/workflows/README.md)
- [旁支流程目录](docs/workflows/)
- [所有 skill 详细手册索引](docs/skills/README.md)
