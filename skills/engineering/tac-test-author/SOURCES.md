# 参考来源：test-author

## 借鉴的 reference 文件

- `reference/mattpocock/skills/engineering/tdd/SKILL.md`
- `reference/superpowers/skills/test-driven-development/SKILL.md`
- `reference/superpowers/skills/writing-plans/SKILL.md`

## 主要改动

- 只写测试骨架，不写实现代码。
- 断言占位等人签；测试头部强制 REQ-TRACE。
- 默认禁用快照当判定依据。

## 未来局部更新建议

- mattpocock tdd / superpowers test-driven-development 更新时，检查红绿纪律和反模式清单。
- 若项目新增测试框架，同步"输出"路径和模板。

## 改动记录

- 2026-07-03：增加 `tech-design.md` 作为输入；测试设计必须基于 tech-design 中定义的 seams。
