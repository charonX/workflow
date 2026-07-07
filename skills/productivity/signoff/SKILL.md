---
name: signoff
description: 两个循环的切换点。--stage=assertion 是外层设计循环的终点(把契约交给 AI 实现);--stage=feel 是内层实现循环的终点(人验收 AI 产出,不通过则回流修设计)。
disable-model-invocation: true
sources:
  - reference/gstack/plan-eng-review/SKILL.md
  - reference/gstack/design-review/SKILL.md
  - reference/gstack/plan-design-review/SKILL.md
  - reference/mattpocock/skills/engineering/tdd/SKILL.md
  - workflow/design/test-as-contract-workflow.md
---

# signoff

## 何时调用

- `/test-author` 完成后，进入 BUILD 前：`/signoff --stage=assertion`
- QA 完成后，合并前：`/signoff --stage=feel`

## 输入

- `--stage`：必填，`assertion` 或 `feel`
- `--story`：可选，story-id
- 阶段相关文件（见下文）

## 输出

- `.aiassist/stories/<id>/signoff.md`（包含 assertion 和 feel 两个 section）
- assertion 阶段产生 `[test] assertion-signoff for <story-id>` commit
- 更新 `workflow-state.yaml`

## assertion 阶段

### 输入

- `.aiassist/stories/<id>/requirements.md`
- `.aiassist/stories/<id>/test-plan.md`
- 测试文件

### 执行步骤

1. **扫描 REQ 覆盖**：每个 REQ-ID 是否至少有一个测试？
2. **扫描测试头部**：每个测试文件是否有 `REQ-TRACE` 和 `REQ-VERSION`？
3. **扫描占位符**：是否还有 `// TODO: HUMAN ASSERTION`？
4. **审查预期值来源**：向用户确认每个关键预期值是人算/真实 JSON/已签标准，而非代码输出。
5. **展示检查清单**：让用户逐项确认。
6. **生成/更新 signoff 文件**：填写 `signoff.md` 中 Assertion 部分的 REQ-ID 列表和断言摘要，确保所有检查清单项已勾选。
7. **提交签核 commit**：用户确认后，执行：
   ```bash
   git add .aiassist/stories/<id>/signoff.md
   git commit -m "[test] assertion-signoff for <story-id>"
   ```
8. **更新 workflow-state**：标记 assertion-signoff 通过，解锁 BUILD。

### 检查清单

- [ ] 每个 REQ-ID 都有对应测试。
- [ ] 每个测试文件都有 `REQ-TRACE` 和 `REQ-VERSION`。
- [ ] 无 `// TODO: HUMAN ASSERTION` 占位。
- [ ] 预期值来源清晰，非代码输出。
- [ ] 无快照当判定依据。
- [ ] 边界/错误 case 已覆盖。
- [ ] `signoff.md` Assertion 部分已创建并通过 `[test] assertion-signoff for <story-id>` commit 提交。

## feel 阶段

### 输入

- `.aiassist/stories/<id>/ux/*.html`
- `.aiassist/stories/<id>/ux/preview.html`（自包含预览页）
- `.aiassist/stories/<id>/ux/_d_meta.json`（资产注册表 + 设计系统绑定）
- `.aiassist/stories/<id>/ux/_ds_manifest.json`（story 级组件清单，如有）
- `.aiassist/stories/<id>/requirements.md`
- 已实现的产品/app
- `.aiassist/stories/<id>/qa-report.md`
- `.aiassist/stories/<id>/signoff.md`（Assertion 部分应已存在）

### 执行步骤

1. **读取 `_d_meta.json`**：确认 canonical 资产列表、各 asset 状态（needs-review/approved/changes-requested）、设计系统绑定。
2. **展示 `preview.html` 和当前实现**给用户。
3. **对照 HTML 原型检查**：结构、元素顺序、颜色、排版、间距、动效、交互反馈、错误/降级状态。
4. **读取 implementer 记录的偏差**：查看实现与 HTML 原型的已知偏差，确认是否在可接受范围。
5. **记录偏差并分类**：
   - **缺陷**：实现偏离已签 REQ → 补标准增量 → 测试 → 实现。
   - **需求变更**：REQ 没写或写错 → 改 REQ → 重签 assertion → 测试 → 实现。
   - **可接受偏差**：HTML 原型无法 1:1 翻译（平台限制等）→ 记录并放行。
6. **生成/更新 signoff 文件**：填写 `signoff.md` 中 Feel 部分的检查结果和偏差列表。
7. **更新 workflow-state**：标记 feel-signoff 通过或退回。

### 检查清单

- [ ] 产品在目标环境启动无崩溃。
- [ ] 关键用户流程可走完。
- [ ] `preview.html` 已生成且能正常渲染。
- [ ] `_d_meta.json` 中所有 asset 状态已确认（needs-review → approved/changes-requested）。
- [ ] 视觉层面对照 HTML UX 参照：结构、元素顺序、颜色、排版、间距、动效。
- [ ] 无系统错误弹窗 / 空白页。
- [ ] 降级/错误状态表达温和、不焦虑。
- [ ] implementer 报告的偏差已被确认。

## 纪律

- **assertion 不通过禁止 BUILD**。
- **feel 不通过禁止合并**。
- 两个阶段都**禁止直接改代码**；偏差必须回流到最高出错层（REQ 或 PRD）。
- 签核 commit 即视为人对"什么算对"承担最终责任。
- assertion 阶段签核 commit 只应修改 `signoff.md`，不应同时修改测试文件或实现代码。

## 与参考项目的差异

- gstack `plan-eng-review` / `design-review` 被收窄为两个签核门。
- mattpocock `tdd` 强调测试先行；我们升级为"人签测试才算契约"。
- 核心差异：用统一 skill 入口管理功能与视觉签核，减少用户记忆成本；用 Git commit 替代手写签名，签核证据更可靠。
