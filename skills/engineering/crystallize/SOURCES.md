# 参考来源：crystallize

## 理念

需求必须可被追踪，才能被测试。本 skill 把 PRD 中的稳定块冻结成带 REQ-ID 和 version hash 的验收标准，建立从"用户痛点 → PRD → REQ → 测试 → 实现"的不可断链路。

## 借鉴的 reference 文件

- `reference/mattpocock/skills/engineering/grill-with-docs/SKILL.md`
- `reference/gstack/plan-eng-review/SKILL.md`
- `reference/superpowers/skills/writing-plans/SKILL.md`

## 主要改动

- 把"文档是否清晰到能写测试"的审查视角固化为验收标准。
- REQ 是测试唯一出生地；每条标准必须反向挂测试。
- 引入 REQ-ID 和 version hash。

## 未来局部更新建议

- mattpocock grill-with-docs 更新时，检查验收标准清晰度要求。
- gstack plan-eng-review 更新时，检查边界情况挖掘清单。

## 改动记录

- 2026-07-03：补全 SKILL.md 执行步骤；增加模块边界属性（scope/modules/interface_contract）和 REQ 分类维度，强调跨模块 REQ 必须显式接口契约；增加 `tech-design.md` 作为输入，增加技术可行性预演步骤。
- 2026-07-01：整理参考来源，明确借鉴的 reference 文件。
