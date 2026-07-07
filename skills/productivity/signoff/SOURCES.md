# 参考来源：signoff

## 理念

两个循环的切换点必须显式化。本 skill 把外层设计循环的终点（门 1：断言签核，把契约交给 AI）和内层实现循环的终点（门 2：观感验收，把 AI 产出交回给人）合并为一个入口；不签字不准切换循环，签字后契约生效，偏差必须回到契约层修正。

## 借鉴的 reference 文件

- `reference/gstack/plan-eng-review/SKILL.md`
- `reference/gstack/design-review/SKILL.md`
- `reference/gstack/plan-design-review/SKILL.md`
- `reference/mattpocock/skills/engineering/tdd/SKILL.md`

## 主要改动

- 把 assertion-signoff 和 feel-signoff 合并为单一 `/signoff` 入口。
- `--stage=assertion` 在实现前签核功能断言。
- `--stage=feel` 在实现后验收视觉，读取 implementer 记录的 HTML 偏差。
- assertion 阶段仍用 `[test] assertion-signoff for <story-id>` commit 留痕。

## 未来局部更新建议

- gstack plan-eng-review / design-review 更新时，检查签核维度和检查清单。
- mattpocock tdd 更新时，检查测试先行与断言归属的表述。

## 改动记录

- 2026-07-05：合并 tac-assertion-signoff 与 tac-feel-signoff 为 tac-signoff。
