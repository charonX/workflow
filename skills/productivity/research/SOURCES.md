# 参考来源：research

## 理念

一挡探索不应只依赖直觉。本 skill 用背景研究补充需求/技术决策，限定 primary sources，明确引用纪律；产出是 `.aiassist/stories/<id>/research/` 中的结构化笔记，为 PRD 和技术方案提供可审计的输入。

## 借鉴的 reference 文件

- `reference/mattpocock/skills/engineering/research/SKILL.md`

## 主要改动

- 适配 test-as-contract 流程：输出到 `.aiassist/stories/<id>/research/`，作为一挡探索产物。
- 明确与 `/demand-insight`、`/tech-design`、`/to-prd` 的边界。
- 增加输出格式模板和引用纪律。
- 限定为 primary sources，减少二手资料污染决策。

## 未来局部更新建议

- mattpocock research skill 若增加新的来源类型或输出格式，同步到这里。
- 若 workflow 引入 issue tracker，可考虑把 research 笔记与 tickets 关联。

## 改动记录

- 2026-07-06：新建 `/research`，补技术调研缺口。
