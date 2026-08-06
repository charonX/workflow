# 参考来源：signoff

## 理念

外层设计循环的终点必须显式化。本 skill 是门 1：断言签核，把契约交给 AI。不签字不准 BUILD，签字后契约生效，偏差必须回到契约层修正。观感/feel 验收已合并到 `/reflect` 和 bug 循环，不再由 `/signoff` 处理。

## 借鉴的 reference 文件

- `reference/gstack/plan-eng-review/SKILL.md`
- `reference/gstack/design-review/SKILL.md`
- `reference/gstack/plan-design-review/SKILL.md`
- `reference/mattpocock/skills/engineering/tdd/SKILL.md`

## 主要改动

- `/signoff` 仅保留 `--stage=assertion`，作为外层设计循环终点（门 1）。
- 实现前签核功能断言，确认每个 REQ 有测试、测试有 trace 头、预期值来源清晰。
- assertion 阶段仍用 `[test] assertion-signoff for <story-id>` commit 留痕。
- 原 feel-signoff 功能已合并到 bug 循环和 `/reflect`：实现偏差登记为 `/file-bug`，最终验收在 `/reflect` 完成。

## 未来局部更新建议

- gstack plan-eng-review / design-review 更新时，检查签核维度和检查清单。
- mattpocock tdd 更新时，检查测试先行与断言归属的表述。

## 改动记录

- 2026-07-10：取消 feel-signoff，`/signoff` 只保留 assertion 阶段。
- 2026-07-05：合并 tac-assertion-signoff 与 tac-feel-signoff 为 tac-signoff。
- 2026-08-06：PRD 与 tech-design 合并（`design/adr/0004`）：签核清单补"PRD §10 技术方案完整性（complex 必须完整）"。
- 2026-08-06：快速收敛哲学（`design/adr/0005`）：签核收敛到**只签高风险项**（初衷/跨模块契约/expected 值/安全边界/GAP 归类），其余改 AI 自检；移除 `prd-gap-report.md` 检查，改为"每个 GAP 已归类"。
