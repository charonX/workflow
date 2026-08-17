# ADR 0008: /review 重构——无 stage 的 cover 自适应并行审查（末端统一）

## Status

Accepted（2026-08-17）。

## Context

ADR 0007 把门 1 改成按需升级门后，REQ/test 层的人工质检点从流程里消失了。`/review` 是承接这个缺口的建议性门，但它有两个问题：

1. **覆盖不到 REQ/test 层**：接口只有 `--stage=prd` 和 `--stage=code`，而门 1 自动化后，REQ（crystallize 产物）和测试（test-author 产物）恰恰是最需要新视角检查的——尤其是 `EXPECTED-TRACE` 的诚实性（防"AI 自证"）。
2. **强制按 stage 分次调用**：用户必须在 PRD 后审一次、BUILD 后审一次，心智上按"我现在在哪个 stage"切分。

用户实际使用后提出两点方向：审查要覆盖 REQ/test/PRD/技术方案全层；**不区分 stage**，一次调用按需并行派发不同 specialist 子代理审查对应层级，汇总总结。进一步，用户选择**统一在末端审查**——PRD 生成后不审查，直接走自动链 → BUILD → QA，最后统一 review 一次。

## Decision

1. **`/review` 无 stage**。接口：`/review [--cover=prd,tech,req,test,code] [--mode=panel|single] [--story=<id>]`。`--cover` 缺省 = 自动审查所有输入已存在的层。

2. **cover → specialist 子代理，panel 并行 + 汇总**（默认）。每层一个子代理：`prd-reviewer` / `tech-reviewer` / `req-reviewer` / `test-engineer` / `code-reviewer`；安全、性能为条件派发。父代理等全部返回，汇总到 `review.md`（PASS/WARN/FAIL，任意 CRITICAL → FAIL）。

3. **默认流 = 末端统一审查**：QA 全绿后、REFLECT 前，`/review` 一次审全链五层。移除 PRD 后 / 自动链后的建议检查点。`--cover` 聚焦审查（如 `--cover=req,test`）仍可用。review 保持**建议性**（不阻塞），人显性决策。

4. **`--mode=single`** 保留为轻量回退：不派子代理，单会话按各层维度逐项过。

5. **防 AI 自证的质检点在 test-engineer 维度**：`EXPECTED-TRACE` 诚实性检查（标注的锚点真实存在于 `prd.md` 且值一致）由 test-engineer 子代理承担；prd-reviewer 检查 §6.3/§7/§10.4 锚点完整性。

## 取舍与兜底

- **子代理成本换"一次看全链"**：panel 默认比原单会话成本高，但避免用户按 stage 分次调用的心智负担与漏层。
- **末端统一审查的代价**：PRD 层错误（错锚点/错契约）会静默传播进全绿的测试和代码，只在末端发现 → 回流成本最高。由三层兜底：PRD 对齐子代理（BUILD 内查意图落地）、QA 就地补全（req-gap 默认收敛路径）、自动链升级点（初衷漂移/契约歧义/expected 推导不出/安全边界/范围决策）。这是"快速收敛"（ADR 0005）的延伸：不前载检查，末端收敛。

## 与 ADR 0007 的关系

ADR 0007 把门 1 自动化后，review 成为残余质检点；本 ADR 落地 review 的新形态。承重墙（测试前置、实现者对测试只读、PRD 对齐子代理、初衷锚点）不变。

## 替代方案

- **保留 stage 分次 + 新增 spec stage**：仍按"现在在哪个 stage"心智分次调用，与用户观察（应一次看全链）冲突。
- **中途设置建议检查点（PRD 后/自动链后）**：用户选择统一末端审查，检查点造成多余打断。

## 相关文件

- `skills/productivity/review/SKILL.md`（重写）
- `templates/story/review-report.md.template`
- `skills/productivity/story/SKILL.md`（D. 手动审查）
- `design/adr/0007-auto-assertion-with-on-demand-escalation.md`
- `design/adr/0005-iterate-fast-converge.md`
