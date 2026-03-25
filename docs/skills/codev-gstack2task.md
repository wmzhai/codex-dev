# `$codev-gstack2task`

Source: `codev`

## Purpose

把 `~/.gstack/projects/` 下的 design doc、implementation handoff、test plan 等上游工件，结合当前代码收敛成 repo 内 task 文件和 task 分支；默认只生成一个 task，只有明确确认后才会拆成多个。

## Preconditions

- 当前目录是 git 仓库。
- `~/.gstack/projects/` 存在且能定位到相关 project slug 或工件。
- 允许新建 `tasks/Txx-*.md` 与对应分支。

## Inputs / Source Of Truth

- `~/.gstack/projects/<slug>/` 下的 implementation plan、test plan、design doc、CEO handoff
- 当前代码结构与模块落点
- 现有 `tasks/`、`tasks/done/`

## Produces / Writes

- 一个或多个 `tasks/Txx-*.md`
- 对应 task 分支
- task 文件中的实现计划、验证计划和关键代码入口

## Execution Flow

1. 定位 project slug 和与当前分支最相关的最新工件。
2. 以 implementation / test plan 为主，design / CEO 工件为补充建立约束。
3. 深读相关代码，把上游边界映射到 repo 的真实文件、模块和调用链。
4. 默认先收敛成一个可执行 task；只有判断必须拆分时，才先向用户展示多个 task 的内容清单并等待确认。
5. 顺延任务编号，并为每个 task 准备独立分支。
6. 写入带 `Implementation Plan`、`Validation Plan` 的 task 文件。

## Stops / Failure Modes

- project slug 无法定位。
- 多份工件相互冲突，无法安全判断以哪份为准。
- 当前仓库和工件的对应关系不明确。
- Codex 判断必须拆成多个 task，但用户尚未确认拆分清单。

## Next Recommended Steps

- 人工审核 task plan
- 认可后进入 `$codev-taskdev`
- 若要自动推进到分支部署，则进入 `$codev-autodev`
