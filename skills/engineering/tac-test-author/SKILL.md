---
name: tac-test-author
description: 从 REQ 生成可执行测试骨架，用占位符标记等人签断言。不写实现代码。
sources:
  - reference/mattpocock/skills/engineering/tdd/SKILL.md
  - reference/superpowers/skills/test-driven-development/SKILL.md
  - reference/superpowers/skills/writing-plans/SKILL.md
  - workflow/design/test-as-contract-workflow.md
---

# test-author

## 何时调用

`requirements.md` 已确认，用户说"写测试骨架"、"/tac-test-author"时。或被 `/tac-story` 总入口调用。

## 输入

- `.aiassist/stories/<id>/requirements.md`
- `.aiassist/stories/<id>/requirements-v1.hash`
- `.aiassist/stories/<id>/tech-design.md`
- `.aiassist/stories/<id>/ux/*.html`（如有 UX 原型，作为结构与行为测试的输入）

## 输出

- `BanshanJourneyTests/**/*.swift`（或项目对应测试目录）
- `.aiassist/stories/<id>/test-plan.md`

## 执行步骤

1. **逐条读取 REQ 与 tech-design.md**：按 tech-design 中定义的 seams，为每条验收标准设计至少一个测试方法。
2. **读取 HTML UX 原型**：如果 `ux/` 目录存在，扫描所有 `.html` 文件，提取可验证的行为与结构项：
   - 关键元素是否存在（如按钮、表单、列表、空态提示）。
   - 页面/组件之间的导航流程（点击 A → 出现 B）。
   - 交互状态（loading、empty、error、success、disabled）。
   - 数据驱动的列表/卡片结构。
   - 与 token.css 关联的 class/style 是否被正确引用（不验证具体像素值）。
   把这些可验证项映射到对应 REQ-ID，补充进测试计划。
3. **写测试文件头部**：必须包含 `REQ-TRACE`、`REQ-VERSION`、`TEST-AUTHOR`、`ASSERTIONS-SIGNED`。
4. **搭建脚手架**：
   - 必要的 import、`@testable import`、setUp/tearDown
   - mock/fixture（如 `MockHealthKitManager`、`TestContainer`）
   - 调用被测对象的代码
5. **占位断言**：在需要人拍预期值的地方写 `// TODO: HUMAN ASSERTION`。
6. **编译检查**：确保测试文件能编译（可能需要临时 stub 实现）。
7. **输出 test-plan.md**：列出每个 REQ-ID 对应哪些测试方法，并标注哪些测试来自 HTML 原型映射。

## 测试头部模板

```swift
// REQ-TRACE: REQ-P0-001, REQ-P0-002
// REQ-VERSION: v1-hash:a3f7d2e
// TEST-AUTHOR: agent
// ASSERTIONS-SIGNED: false
```

## 纪律

- **只写测试，不写实现代码**。
- 预期值**不**从当前代码抄写；用占位符等人签。
- 默认**禁用快照当判定依据**。
- 能用单元测的，不进 E2E（缺陷下沉原则）。
- 覆盖：正常路径 + 边界 + 错误路径。
- **HTML 原型是测试输入**：从 HTML 中提取行为和结构，但不把主观视觉（如“间距 12px 才好看”）写进测试。

## 与参考项目的差异

- mattpocock `tdd`：给我们"红绿重构"和测试先行的纪律。
- superpowers `test-driven-development`：给我们铁律和常见反模式清单。
- 核心差异：测试作者和实现者必须分离；断言归人。
