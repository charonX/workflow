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
- 2026-08-06 起：PRD 吸收 tech-design 内容（§10 技术方案 / §11 测试决策），不再产出独立 `tech-design.md`。§9 复杂度分级决定结晶路径：`complex` → 结晶前调用 `/tech-design` 深潜补全 §10；`simple` → 直接填 §10 高层 + §11 seams 后结晶。to-prd 定稿时写 `phase=DESIGN`。

## 未来局部更新建议

- superpowers writing-plans 的 header 格式若更新，同步文档头。
- mattpocock to-spec 若更新 spec 结构（Implementation/Testing Decisions），检查 §10/§11 章节划分。

## 改动记录

- 2026-07-03：增加模块/服务边界识别步骤，强调快速增长项目提前解耦，PRD 模板新增"模块/服务边界"和"覆盖接缝"字段。
- 2026-08-06：PRD 与 tech-design 合并（见 `design/adr/0004-merge-prd-and-tech-design.md`）：§10 技术方案、§11 测试决策折入 prd.md；tech-design 改条件深潜；to-prd 写 `phase=DESIGN`。
- 2026-08-06：快速收敛哲学（`design/adr/0005`）：完整性自检查改为补缺口首要场所；GAP 强制四分法归类（就地补/移动块/新建 story/范围外），无悬空。
