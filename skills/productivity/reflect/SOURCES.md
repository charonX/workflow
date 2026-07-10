# 参考来源：reflect

## 理念

外层设计循环的反馈。工作流的价值一半在交付，一半在学习。本 skill 在每次 story 结束后提取经验教训，把个人直觉沉淀为项目级知识（`STANDARDS.md`、`engineering-lessons.md`），让下一个 story 的设计上下文更准确，同一错误不被重复支付。

## 借鉴的 reference 文件

- `reference/gstack/retro/SKILL.md`
- `reference/superpowers/skills/writing-plans/SKILL.md`

## 主要改动

- 简化为个人/OPC 经验沉淀。
- 与 REQ-ID 腐化指标、`/signoff --stage=feel` 发现率挂钩。
- 新增 `checklists/` 维护职责：根据 story 经验更新 testing/security/performance/accessibility/observability 清单。
- **v0.12.0 起**：新增 bug 循环指标（bug 总数、类别分布、平均修复轮数、回补文档数）。

## 未来局部更新建议

- gstack retro 更新时，同步复盘结构。
- superpowers writing-plans 更新时，检查 ADR 格式。

## 改动记录

- 2026-07-03：增加 design pattern 沉淀检查项，复盘时判断是否产生可复用模式并写入 `STANDARDS.md` / `engineering-lessons.md`。
- 2026-07-09：新增 `checklists/` 维护职责；`/reflect` 根据 story 经验更新 testing/security/performance/accessibility/observability 清单。
- 2026-07-10：新增 bug 循环健康指标。
