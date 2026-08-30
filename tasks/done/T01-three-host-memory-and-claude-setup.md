# T01: 三宿主入口、按客户端安装，以及跨工具接手

Source: User prompt

## Source Context

- 用户要求在现有 Codex / Grok 支持上补 Claude Code：安装后可在 Claude Code 里使用 `codev-*`，`memorize` 等指令的内容也要认识 Claude Code。
- 确认：三个宿主分开写入口 md，公共事实只维护一份；`./setup` 先探测本机客户端，装了才安装或更新，没装就跳过。
- 确认：被 `codev-memorize` 初始化过的项目，无论当初用 GPT、Grok 还是 Claude 写的，另外两家都要能无障碍接手。

## Task Description

把 codev 从「Codex + Grok 双宿主、单一 `AGENTS.md` 入口」扩成「Codex / Grok / Claude Code 三宿主」。分两层，不要混在一起：

1. **本机安装层（`setup`）**
   - 探测 PATH 里是否有 `codex`、`grok`、`claude`。
   - 有哪个客户端，就安装或幂等更新对应全局 skills。
   - 没有就不创建、不更新该宿主目录，打印跳过。
   - 三个都没有则失败退出，并说明需要先装客户端。
   - Claude Code 的链接方式对齐 Grok：只把受管 skill 链到 `~/.claude/skills/<name>`，不挂整仓 `codev`，并清掉历史遗留的 `~/.claude/skills/codev`。
   - 不恢复 `--host`，不支持项目内 vendored 安装，不写 `~/.agents/skills`，不做成 Claude marketplace plugin。

2. **项目记忆层（本仓库 + `codev-memorize`）**
   - 公共事实只写在 `memory/`。
   - 三个分开入口：
     - Codex：`AGENTS.md`
     - Claude Code：`CLAUDE.md`
     - Grok：`.grok/rules/memory.md`（Grok 不自动读根目录 `GROK.md`，所以不用根目录那个名字）
   - 每份入口只放：宿主身份、宿主守卫、一两句硬规则（默认中文、公共事实在 `memory/`）、宿主专用调用前缀/路径、指向 `memory/`。
   - **无论当前会话是哪家模型，`codev-memorize` 都必须一次写齐公共 `memory/` 和三份入口。** 禁止因为「这轮是 GPT 在跑」就只写 `AGENTS.md`。这是跨工具接手的硬约束。
   - 落盘的 `memory/`、`docs/`、`README.md` 写 skill 调用时同时列出三家前缀；当前对话里仍只提示当前宿主的那一套。

本仓库自己也要按这套结构改完，既是 codev 的真实入口，也是 `codev-memorize` 的样板。

## Acceptance Criteria

- [x] 无参 `./setup` 只对 PATH 中存在的 `codex` / `grok` / `claude` 安装或更新 skills；缺失的宿主打印跳过且不创建其 skills 目录。
- [x] PATH 中一个受支持客户端都没有时，`setup` 以非 0 退出，并说明需要 `codex`、`grok` 或 `claude`。
- [x] 探测只认 `command -v` 对应命令，不把 `~/.codex` 等配置目录存在当成已安装，也不把 macOS 自带的 `gpt` 当成 Codex。
- [x] Claude Code 安装布局与 Grok 相同：`~/.claude/skills/<skill>` 指向仓库内 `skills/<skill>` 的绝对路径；不创建 `~/.claude/skills/codev`；若该遗留链接指向本仓库则删除。
- [x] Codex / Grok 现有布局不变：Codex 仍链整仓 `codev` 加相对 skill 链接；Grok 仍只链各个 skill。
- [x] 本仓库存在三份入口，且公共事实不在三份入口里各写一遍长文：`AGENTS.md`、`CLAUDE.md`、`.grok/rules/memory.md`，详细约束在 `memory/`。
- [x] 每份入口都有宿主守卫：当前宿主不是自己时，忽略该文件里的专用前缀规则，只走 `memory/`。
- [x] `codev-memorize` 的 `SKILL.md` 明确要求：对任意目标仓库都写齐 `memory/` + 三份入口；不按当前宿主裁剪；已有入口里的宿主专用段落保留，不把仓库事实再抄一份。
- [x] 面向用户的对话提示按当前宿主写前缀：Codex `$name`，Grok `/name`，Claude Code `/name`。落盘文档同时写三家，不能只留 Codex `$` 当唯一模板。
- [x] `./test/setup-smoke.sh` 覆盖全装、单宿主、混装、全无失败、冲突失败、幂等更新。
- [x] `./test/skill-invocation-prefix.sh` 覆盖 Claude Code 与三入口文件。
- [x] `./test/version-rules.sh` 在公共规则迁走后仍然通过（断言改到 `memory/core/invariants.md` 等实际落点）。
- [x] 不恢复 `--host`，不引入项目内 `.claude/skills/` vendored 安装，不把 `CLAUDE.md` 做成第二份完整记忆正文。

## Related Code

- `setup` - 当前无参同时装 Codex 和 Grok，不探测客户端，不装 Claude。
- `test/setup-smoke.sh` - 用假 `HOME` 断言双宿主链接；改探测后若不注入假二进制，会变成「全跳过然后失败」。
- `test/skill-invocation-prefix.sh` - 只断言 Codex `$` 与 Grok `/`。
- `test/version-rules.sh` - 把若干仓库规则断言写在 `AGENTS.md` 上；入口变薄后这些字符串应落到 `memory/core/invariants.md`。
- `skills/codev-memorize/SKILL.md` - 只维护 `AGENTS.md + memory/`，明确不再维护额外入口。
- `skills/codev-issue2task/SKILL.md`、`skills/codev-taskdev/SKILL.md` - 已有「调用前缀」，缺 Claude Code。
- `skills/codev-checkpoint/SKILL.md`、`skills/codev-quickship/SKILL.md` 及各 `docs/skills/*.md` - 宿主对照目前只有 Codex / Grok。
- `AGENTS.md`、`README.md`、`docs/workflows.md`、`memory/core/*` - 仍按「Codex + Grok、单一 AGENTS 入口」叙述。
- 历史：`55e607b` 去掉 `CLAUDE.md` 记忆入口；`4b66939` 去掉 Claude 安装。这次是有公共层的三入口，不是恢复旧的双份正文。

## Implementation Plan

### Proposed Approach

沿用 Grok 安装模式扩展第三个宿主，记忆层改成「`memory/` 一份公共正文 + 三份短入口」。Grok 会同时加载 `AGENTS.md` 和 `CLAUDE.md`，所以入口必须有宿主守卫，公共事实不能在两份入口里重复写成会打架的前缀规则。

放弃的路径：
- 不恢复 `--host`：探测已经表达「这台机器有谁」。
- 不把 `CLAUDE.md` 做成 `AGENTS.md` 的完整副本或 symlink：那会重新引入双份记忆，Grok 也会吃到两套前缀。
- 不用根目录 `GROK.md`：Grok 官方不扫这个文件名；用 `.grok/rules/memory.md`，本仓库和 memorize 目标仓库同一约定。
- 不按本机已装客户端裁剪项目文件：项目要给别人接手，和这台机器装了谁无关。

### File Changes

- `setup` - 增加 `claude` 探测与 `install_for_claude`（Grok 同款链接 + 清理遗留 `codev` 链接）；`codex`/`grok`/`claude` 均先 `command -v` 再安装；全无则 `die`；更新无参说明。
- `test/setup-smoke.sh` - 在临时 `PATH` 放入假客户端脚本；覆盖 0/1/2/3 个宿主、冲突、幂等、跳过的宿主目录不存在。
- `AGENTS.md` - 改成 Codex 短入口：守卫、默认中文、指向 `memory/`、`$` 前缀、`~/.codex/skills`。仓库定位、skill 边界、版本规则等公共正文迁出。
- `CLAUDE.md` - 新建 Claude Code 短入口：守卫、默认中文、指向 `memory/`、`/` 前缀、`~/.claude/skills`。
- `.grok/rules/memory.md` - 新建 Grok 短入口：守卫、默认中文、指向 `memory/`、`/` 前缀、`~/.grok/skills`。
- `memory/core/invariants.md` - 成为公共高优先级规则落点：安装探测、三入口约定、跨工具接手、调用前缀（对话按当前宿主，落盘写三家）、`memorize` 必须写齐三入口。去重，不要和入口长文重复。
- `memory/core/system-map.md`、`memory/core/workflows.md`、`memory/core/scope.md`、`memory/core/symptom-routing.md`、`memory/README.md` - 改为三入口 + 公共 `memory/`，去掉「不再维护额外入口文件」和「只服务 Codex」。
- `skills/codev-memorize/SKILL.md`、`skills/codev-memorize/agents/openai.yaml`、`docs/skills/codev-memorize.md` - 目标结构、扫描信号、产出物、跨宿主写齐规则、已有入口的保留策略。
- `skills/codev-issue2task/SKILL.md`、`skills/codev-taskdev/SKILL.md` - 调用前缀补 Claude Code；判断依据含 Claude Code 会话。
- `skills/codev-checkpoint/SKILL.md`、`skills/codev-quickship/SKILL.md` - Codex / Grok / Claude 三套触发写法。
- `docs/skills/*.md`、`docs/skills/README.md`、`docs/workflows.md`、`README.md` - 安装说明、三入口导航、落盘前缀写三家。
- `test/skill-invocation-prefix.sh` - 断言三宿主前缀和三份入口文件；README / workflows 不再只写「Grok 把 `$` 换成 `/`」这一种句式。
- `test/version-rules.sh` - 原贴在 `AGENTS.md` 上的仓库规则断言改到 `memory/core/invariants.md`（或实际仍保留这些句子的公共文件）。
- `CHANGELOG` - 在 Unreleased 记录本轮行为。

### Execution Order

1. 改 `setup`：抽出「是否安装客户端」判断；为 Claude 写与 Grok 对称的 `install_for_claude`；主流程按探测结果调用；全无则失败。保持 Codex / Grok 链接语义不变。
2. 重写 `test/setup-smoke.sh`：用 `TMP/bin` 里可执行的 `codex`/`grok`/`claude` 假命令控制 PATH。先落地「三宿主全装」与「一个都没有」两条，再补单宿主、混装、冲突、遗留 `~/.claude/skills/codev` 清理。
3. 把当前 `AGENTS.md` 里宿主无关的仓库定位、维护规则、版本/收口约束合并进 `memory/core/invariants.md`，去掉过期的「单一 AGENTS 入口」「setup 必须同时刷新 Codex 和 Grok」。
4. 把 `AGENTS.md` 收成 Codex 短入口；新增 `CLAUDE.md` 与 `.grok/rules/memory.md`。三份都含宿主守卫和指向 `memory/` 的读法。
5. 更新其余 `memory/` 导航，使热路径变成「读自己的入口 → `memory/README.md` → `memory/core/`」。
6. 改 `codev-memorize`：目标结构含三入口；初始化/刷新都写齐；扫描 `CLAUDE.md` 与 `.grok/rules/`；已有宿主专用段落保留；落盘文档写三家前缀。
7. 给 `issue2task` / `taskdev` / `checkpoint` / `quickship` 以及相关 `docs/skills` 补 Claude Code；对话判断加上 Claude Code。
8. 更新 `README.md`、`docs/workflows.md`、`docs/skills/README.md`：安装探测、三入口、调用前缀。
9. 更新 `skill-invocation-prefix.sh` 与 `version-rules.sh`，跑全部现有测试脚本。
10. 在 `CHANGELOG` Unreleased 写一条准确摘要。

### Assumptions / Open Questions

- Grok 入口文件名用 `.grok/rules/memory.md`，本仓库与 memorize 目标仓库同一约定；不用根目录 `GROK.md`，也不用 `codev.md`（避免目标项目被写死 codev 名）。
- `agents/openai.yaml` 仍是 Codex UI 元数据，`default_prompt` 可以继续用 `$codev-*`，不必改成三套。
- 入口里的「一两句硬规则」至少包含：默认中文、公共事实在 `memory/`、先读 `memory/README.md` 与 `memory/core/invariants.md`。
- 若目标仓库已有内容丰富的 `CLAUDE.md`，memorize 只把重复的仓库事实迁到 `memory/`，保留 Claude 专用约束，再补守卫和跳转，不整文件覆盖。
- 本机新装某个客户端后，需要再跑 `./setup` 才会链上该宿主 skills；这是安装层，不在 memorize 里模拟。

## Validation Plan

- [x] `bash -n setup`
- [x] `./test/setup-smoke.sh`（全装 / 单宿主 / 混装 / 全无 / 冲突 / 幂等 / Claude 遗留 `codev` 链接清理）
- [x] `./test/skill-invocation-prefix.sh`
- [x] `./test/version-rules.sh`
- [x] `./test/issue2task-input-rules.sh`
- [x] 人工抽查：三份入口都很短、有守卫、指向 `memory/`；`memory/core/invariants.md` 仍有 skill 边界和版本规则；`codev-memorize/SKILL.md` 写明「当前是哪家宿主都要写齐三入口」。
- [x] 本机真实 `./setup`：Codex / Grok / Claude Code 均刷新；`~/.claude/skills/codev-memorize` 指向仓库 skill 目录；无 `~/.claude/skills/codev`。

## Status

已归档到 `tasks/done/`

## Execution Log

- 保留工作区里已有的 `skills/codev-taskdev/SKILL.md` 未提交改动，只在其上补 Claude Code 调用前缀。
- `setup` 按 `command -v` 探测 `codex` / `grok` / `claude`；Grok 与 Claude 共用直接链接函数；全无客户端则失败。
- `test/setup-smoke.sh` 用隔离 PATH 覆盖全装、单宿主、混装、全无、冲突、幂等和 Claude 遗留 `codev` 链接清理。
- `AGENTS.md` 收成 Codex 短入口；新增 `CLAUDE.md` 与 `.grok/rules/memory.md`；公共规则并入 `memory/core/invariants.md`。
- `codev-memorize` 改为无论当前宿主都写齐三入口；各 skill / docs 补 Claude Code 前缀。
- 收尾精简：去掉 `invariants.md` 里重复的 taskdev/quickship 条目；修正前缀测试里反引号被 shell 执行的问题。
- 本机 `./setup` 已把受管 skills 链到 `~/.claude/skills/`。

## Implementation Notes

- Grok 入口文件名按 plan 使用 `.grok/rules/memory.md`，本仓库与 memorize 目标仓库同一约定。
- `agents/openai.yaml` 仍用 `$codev-*`，只服务 Codex UI。
- 无数据库迁移；本仓库校验入口是 `test/*.sh`，不是 `pnpm build`。

## Pending Validation

- [x] 用户触发 `/codev-quickship`，表示 Claude Code 斜杠入口与跨宿主接手的人工验收已完成。

## Remaining Gaps

- 无功能缺口。

## Dependencies

None

## Notes

- 跨工具接手分两层：项目层靠三入口 + 公共 `memory/`；本机层靠 setup 探测。不要把「这台机器没装 Claude」写成可以少写 `CLAUDE.md`。
- 历史提交 `55e607b` / `4b66939` 去掉的是「CLAUDE.md 当第二份正文」和「无探测的 Claude 安装」。这次不要把那两件事原样加回来。
- 对话里提示下一步时，当前宿主是 Grok，写 `/codev-taskdev`，不要写 `$codev-taskdev`。
