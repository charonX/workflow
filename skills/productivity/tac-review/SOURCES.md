# 参考来源：tac-review

## 借鉴的 reference 文件

- `reference/gstack/review/SKILL.md`
- `reference/gstack/plan-eng-review/SKILL.md`
- `reference/mattpocock/skills/engineering/code-review/SKILL.md`

## 主要改动

- 设计为手动触发，支持 `prd` / `tech` / `code` 三个阶段。
- 强调在新 Claude Code 会话中调用，避免上下文偏见。
- 输出结构化 review 报告，但不自动修改产物。
- 建议性而非强制性；回流决策由人做。

## 未来局部更新建议

- gstack review 更新时，检查代码审查维度和报告格式。
- gstack plan-eng-review 更新时，检查计划/架构审查清单。

## 改动记录

- 2026-07-04：创建 skill，定义三阶段手动 review 流程与报告模板。
