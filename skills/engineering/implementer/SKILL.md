---
name: implementer
description: 在测试契约内自主实现代码。对测试只读，每轮迭代跑全套单元测试，直到全绿。
sources:
  - reference/superpowers/skills/subagent-driven-development/SKILL.md
  - reference/superpowers/skills/executing-plans/SKILL.md
  - reference/superpowers/skills/writing-plans/SKILL.md
  - reference/mattpocock/skills/engineering/implement/SKILL.md
  - workflow/design/test-as-contract-workflow.md
---

# implementer

## 何时调用

assertion-signoff 已通过，用户说"开始实现"、"/implementer"时。或被 `/test-as-contract` 总入口调用。

## 输入

- `.aiassist/stories/<id>/requirements.md`
- `BanshanJourneyTests/**/*.swift`
- `.aiassist/stories/<id>/assertion-signoff.md`

## 输出

- 实现代码（`BanshanJourney/**/*.swift` 或项目对应源码目录）
- 每轮迭代报告（隐式）

## 执行步骤

1. **读取测试**：理解每个测试的输入、输出、断言。
2. **内循环实现**：
   - 写最小实现使某个测试变绿。
   - 跑 **全套单元测试**（不是只跑当前测试）。
   - 如果回归失败，先修回归。
   - 重复直到全绿。
3. **轮数上限**：超过 N 轮（默认 10 轮）仍未全绿，停止并 escalate。
4. **Escalation 姿势**：
   - "我实现不出来，诊断如下" → 升级给人/更强模型。
   - "我怀疑断言 X 自相矛盾/不可满足，证据如下" → 回 assertion-signoff。
5. **提交**：全绿后 commit。

## 内循环命令

```bash
cd /Users/zhanglei/charon/code/workspace/BanshanJourney
xcodebuild -project BanshanJourney.xcodeproj -scheme BanshanJourneyTests -destination 'platform=iOS Simulator,name=iPhone 17' test 2>&1 | grep -E "(Test Suite|Executed|failures)"
```
Expected: `Executed N tests, with 0 failures (0 unexpected)`

## 纪律

- **对测试只读**：禁止修改 `BanshanJourneyTests/` 内任何文件。
- **diff 碰测试 = 本轮作废**。
- **每轮跑全套单元**：停机条件是"全套绿"。
- **不擅自放宽断言**。
- **不跳过看起来"无关"的失败**。

## 与参考项目的差异

- superpowers `subagent-driven-development`：给我们 subagent 批量执行、任务简报、review package。
- superpowers `executing-plans`：给我们 inline 批量执行。
- mattpocock `implement`：给我们"按已有上下文实现"的轻量模式。
- 核心差异：测试只读 + 断言归人 + 轮数上限逃生口。
