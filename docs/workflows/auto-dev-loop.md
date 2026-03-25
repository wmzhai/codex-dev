# 自动闭环流程

这份文档只讲总流程中的自动旁支：当 task plan 已审核、下游路径较固定时，如何用 codev 自动推进到“已部署待人工确认”，再由人工放行收尾。

## 适用条件

- task plan 已经稳定，且用户明确接受。
- 仓库存在 preview、staging、branch deploy 或等价的非主干验证环境。
- 不需要在每一个实现细节上都暂停等待人工判断。

## 主链路

```text
$office-hours / $autoplan / $plan-*
-> $codev-gstack2task 或 $codev-issue2task
-> 审核 task plan
-> $codev-autodev
-> 人工确认部署结果
-> $codev-quickship 或 $codev-automerge
```

## 分阶段说明

### 1. 先把上游收敛好

- gstack 负责 design doc、plan review、test plan。
- codev 不会替代这层工作；它只消费已经稳定的规划结果。

### 2. task 生成与审核

- `$codev-gstack2task` 或 `$codev-issue2task` 产出 task 文件和分支。
- 人工必须先确认 `Implementation Plan`、`Validation Plan`、边界与风险。

### 3. `$codev-autodev`

- 内含 `$codev-taskdev`：选 task、校准 plan、编码。
- 再继续推进 `$codev-simplify`、中间提交、`$design-review`、`$review`、`$qa`、分支部署与部署后验证。
- 它持续更新 `tasks/Txx-*.md`，并停在“已部署待人工确认”。

### 4. 人工确认

- 看真实部署结果，不是只看代码 diff。
- 如果不通过，就在当前 task 分支继续修，必要时重新跑 `$codev-autodev`。

### 5. `$codev-quickship` / `$codev-automerge`

- 两者都只在人工明确确认后使用。
- `$codev-quickship` 负责快速直推主干：在分支上就 merge 到主干，在主干上就直接 commit + push，不走 PR、版本号或正式发布。
- `$codev-automerge` 负责正式发布式收尾：merge、版本号、正式发布与任务归档。

## 这条旁支不负责什么

- 不替代上游规划。
- 不跳过 task plan 审核。
- `$codev-autodev` 不 merge 主干、不打版本号。
- `$codev-quickship` 与 `$codev-automerge` 都不应提前在“用户未确认”时启动。
