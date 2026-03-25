# `$codev-autodev`

Source: `codev`

## Purpose

在已有 task 分支上自动推进单个 task，从内含的 `$codev-taskdev` 阶段一直做到“已部署待人工确认”。

## Preconditions

- 目标 task plan 已经写好并被用户接受。
- 仓库存在可验证的非主干部署路径。
- 当前 task 的 downstream 流程相对固定，适合自动推进。

## Inputs / Source Of Truth

- `tasks/Txx-*.md`
- task 分支
- 当前代码
- 必要时读取 gstack review / QA / 部署配置

## Produces / Writes

- 代码改动
- 中间提交或 checkpoint
- 更新后的 task 文档
- 分支部署结果与部署后验证结果

## Execution Flow

1. 选择目标 task 与任务分支，读取最新 task 文档。
2. 校准 task 中已有的 `Implementation Plan` / `Validation Plan`。
3. 执行内含的 `$codev-taskdev` 阶段，完成编码与最小本地验证。
4. 继续推进 `$codev-simplify`、中间提交、`$design-review`、`$review`、`$qa` 等必要门禁。
5. 在 task 分支完成 preview、staging 或 branch deploy，并做部署后验证。
6. 持续更新 task 文档，最后停在“已部署待人工确认”。

## Stops / Failure Modes

- 缺凭证、缺权限、缺分支部署能力。
- task plan 尚未稳定，自动决策风险过高。
- 高影响问题需要人工拍板。
- 仓库只能通过 merge 主干来部署。

## Next Recommended Steps

- 人工确认部署结果
- 小改动且允许直推主干时进入 `$codev-quickship`
- 需要正式发布收尾时进入 `$codev-automerge`
- 确认不通过则继续在当前 task 分支修复
