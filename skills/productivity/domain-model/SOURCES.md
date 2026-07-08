# 参考来源：domain-model

## 理念

领域模型是项目的"统一语言"：同样的业务概念在 PRD、代码、测试、对话中必须用同一个词表示。`CONTEXT.md` 不是实现文档，而是业务词汇表，让所有 skill 和人都用同一套语言工作。

## 借鉴的 reference 文件

- `reference/mattpocock/skills/engineering/domain-modeling/SKILL.md`
- `reference/mattpocock/skills/deprecated/ubiquitous-language/SKILL.md`
- `reference/mattpocock/skills/in-progress/wayfinder/SKILL.md`（shared map 思想）

## 主要改动

- 把 mattpocock 的 `domain-modeling` 和 `ubiquitous-language` 合并为一个轻量 skill。
- 明确 `CONTEXT.md` 只包含领域语言，不写实现细节。
- 与双循环工作流集成：/tech-design 前、/reflect 后、/to-prd 中均可触发。
- 增加"代码映射"列，方便从业务术语找到对应实现，但不把实现细节写入定义。

## 未来局部更新建议

- mattpocock domain-modeling 更新时，同步术语挑战方法和 ADR 判定规则。
- ubiquitous-language 更新时，同步表格格式和 aliases 处理。

## 改动记录

- 2026-07-08：创建 skill，维护领域词汇表 CONTEXT.md。
