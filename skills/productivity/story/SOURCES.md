# 参考来源

## 理念

story = 初衷，不是具体方案。本 skill 是工作流总入口：路由用户到当前 story 所处阶段，在签核门切换外层/内层循环，并在发现根本问题时执行回流（归档重做或删 story）。把"推倒重来"做成显式、留证据、可学习的动作，避免沉没成本绑架决策。

这个 skill 参考了以下来源：

| 来源 | 路径 | 借鉴了什么 |
|------|------|-----------|
| test-as-contract 设计 | `workflow/design/test-as-contract-workflow.md` | 10 阶段流程、双 Gate 机制、角色分离 |

## 改动记录

- 2026-07-06：DESIGN 阶段路由统一为 `/design`，合并 `tac-design-system`、`tac-design-import`、`tac-ux-explore` 三个入口。
- 2026-07-05：路由表更新：ASSERTION-SIGNOFF / FEEL-SIGNOFF 统一指向 `/signoff` 的对应 stage。
- 2026-07-03：增加 `TECH-DESIGN` 阶段路由；归档范围增加 `tech-design.md`；阶段列表同步更新。
- 2026-07-02：重命名为 `/story`(原 `/test-as-contract`),补全路由逻辑与回流机制
  - story = 初衷;实现路径错 → 归档重做;初衷错 → 删 story
  - 根因诊断优先;UX 不归档;按块回流不建 attempt
  - 新增 `workflow-state.yaml` 状态机(phase/attempt/history/archive)
- 2026-07-01：更新阶段引导表
  - DESIGN 阶段新增 `/design-import`(可选) 引导
  - REVIEW 阶段新增 `/design-handoff`(可选) 引导
- 2026-06-25：基于设计文档（`workflow/design/`）实现
  - 10 阶段流程映射
  - 双 Gate（`/signoff --stage=assertion` + `/signoff --stage=feel`）
  - 角色分离（human / test-author / implementer）
  - 阶段可跳过逻辑（无 UI 跳 DESIGN，明确需求跳 THINK）
