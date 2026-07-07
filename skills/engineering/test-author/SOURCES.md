# 参考来源：test-author

## 理念

人写断言，AI 写骨架；测试是人与实现之间的契约文本。本 skill 从 REQ-ID 生成可运行的测试结构，为人留出断言占位，确保裁决权始终在人手中。

**CLI 优先。** 能用产品 CLI 验证的行为，先生成 CLI 测试；CLI 测不了的复杂前端交互才退到单元或浏览器 E2E。CLI 是真实用户路径，不是测试专用工具。

## 借鉴的 reference 文件

- `reference/mattpocock/skills/engineering/tdd/SKILL.md`
- `reference/superpowers/skills/test-driven-development/SKILL.md`
- `reference/superpowers/skills/writing-plans/SKILL.md`

## 主要改动

- 只写业务测试骨架（验收测试），不写实现代码。
- 不写 TDD 单元测试；单元测试是 `/implementer` 内部代码纪律。
- seams 类型限定为 CLI、API/public 函数接口、浏览器 E2E。
- 断言占位等人签；测试头部强制 REQ-TRACE。
- 默认禁用快照当判定依据。

## 未来局部更新建议

- mattpocock tdd / superpowers test-driven-development 更新时，检查红绿纪律和反模式清单。
- 若项目新增测试框架，同步"输出"路径和模板。

## 改动记录

- 2026-07-03：增加 `tech-design.md` 作为输入；测试设计必须基于 tech-design 中定义的 seams。
- 2026-07-07：明确区分业务测试与 TDD 单元测试；test-author 只生成业务测试骨架，不写单元测试。
