# 参考来源：to-prd

## 理念

PRD 是测试的唯一出生地，也是后续所有争议的裁判。本 skill 不访谈，只合成；用"稳定块/移动块"显式区分已确定和尚在探索的内容，服务一挡可推翻、二挡才锁定的双挡模型。

## 借鉴的 reference 文件

- `reference/superpowers/skills/writing-plans/SKILL.md`
- `reference/gstack/office-hours/SKILL.md`

## 主要改动

- 不发布到问题跟踪系统，输出到 `.aiassist/stories/<id>/prd.md`。
- 增加 `稳定块` / `移动块` 字段，服务双挡模型。
- 保留"提前想测试 seams"思想。

## 未来局部更新建议

- superpowers writing-plans 的 header 格式若更新，同步文档头。

## 改动记录

- 2026-07-03：增加模块/服务边界识别步骤，强调快速增长项目提前解耦，PRD 模板新增"模块/服务边界"和"覆盖接缝"字段。
