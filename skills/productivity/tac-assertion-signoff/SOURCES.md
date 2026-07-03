# 参考来源：assertion-signoff

## 借鉴的 reference 文件

- `reference/gstack/plan-eng-review/SKILL.md`
- `reference/mattpocock/skills/engineering/tdd/SKILL.md`

## 主要改动

- 把工程审查收窄为"断言签核门"。
- 新增硬门规则：不签不能进 BUILD。
- 增加预期值来源审查。

## 未来局部更新建议

- gstack plan-eng-review 更新时，检查审查维度和清单。
- mattpocock tdd 更新时，检查测试先行契约精神。

## 改动记录

- 2026-07-03：去掉手写签名和日期，改为 Git commit 签核。`[tac-test] assertion-signoff for <story-id>` commit 即视为签核证据。
