---
name: tdd
description: AI 内层循环的代码纪律。针对一个具体功能或 slice，用红-绿循环写单元测试驱动实现。单元测试是实现工具，不进入业务测试契约。
sources:
  - reference/mattpocock/skills/engineering/tdd/SKILL.md
  - reference/mattpocock/skills/engineering/tdd/tests.md
  - reference/mattpocock/skills/engineering/tdd/mocking.md
  - reference/agent-skills/skills/test-driven-development/SKILL.md
  - workflow/design/test-as-contract-workflow.md
---

# tdd

## 何时调用

- `/implementer` 在实现某个 slice 时，需要用单元测试驱动具体函数/模块的实现。
- 用户明确说"用 TDD 实现这个函数"、"红绿重构"、"先写测试"。
- 修复 bug 时，先写一个失败的回归测试，再修复代码。

**TDD 不是工作流阶段，而是 `/implementer` 内部的代码纪律。**

## 输入

- 当前 slice 要满足的业务测试（由 `/test-author` 生成，人已签核）
- `requirements.md` 中本 slice 对应的 REQ-ID 和验收标准
- `tech-design.md` 中本 slice 的模块/接口/seam 设计
- 现有代码库和项目约定

## 输出

- 实现代码
- 单元测试文件（实现工具，不进入契约）
- 一个 `[build]` commit（由调用方 `/implementer` 完成）
- 汇报：RED → GREEN 的证据

## 核心原则

### 单元测试 vs 业务测试

| | 单元测试（TDD） | 业务测试（契约） |
|---|---|---|
| **谁写** | `/implementer` 自动写 | `/test-author` 生成 |
| **什么时候写** | 实现过程中 | 实现前，人签核 |
| **测试对象** | 函数、模块、内部行为 | CLI、API、E2E、用户可观察行为 |
| **是否进入契约** | 否 | 是 |
| **AI 能否修改** | 能，随写随改 | 不能，只读 |
| **作用** | 驱动代码设计、快速反馈 | 证明需求被满足 |

### TDD 是红 → 绿循环

```
1. 读业务测试，明确当前要实现什么行为
2. 写一个会失败的单元测试（RED）
3. 写最少代码让测试通过（GREEN）
4. 可选：简单清理，保持测试绿
5. 回到 1，直到业务测试也绿
```

### 测试金字塔与测试尺寸

按测试金字塔分配投入：大部分测试应该是小而快的，越往上层测试越少。

```
          ╱╲
         ╱  ╲         大型测试 ~5%   — E2E、性能基准、关键用户流程
        ╱    ╲
       ╱──────╲
      ╱        ╲      中型测试 ~15%   — API/组件/集成，localhost 或测试 DB
     ╱          ╲
    ╱────────────╲
   ╱              ╲   小型测试 ~80%   — 纯逻辑、无 I/O、毫秒级
  ╱                ╲
 ╱──────────────────╲
```

| 尺寸 | 约束 | 速度 | 示例 |
|---|---|---|---|
| **小型** | 单进程，无 I/O，无网络，无数据库 | 毫秒 | 纯函数、数据转换 |
| **中型** | 多进程可接受，localhost，无外部服务 | 秒 | API 测试带测试 DB、组件测试 |
| **大型** | 多机可接受，允许外部服务 | 分钟 | E2E 测试、性能基准、staging 集成 |

**Beyonce Rule**：If you liked it, you should have put a test on it. 重构、迁移、基础设施改动不负责捕捉你的 bug —— 你的测试才负责。

**选择指南：**

- 纯逻辑无副作用？→ 小型单元测试
- 跨边界（API、数据库、文件系统）？→ 中型集成测试
- 关键用户流程必须端到端通过？→ 大型 E2E 测试（限制在关键路径）

## 循环规则

### 1. 一次一个 seam

- 一个 seam = 一个 public interface = 一个可观察行为边界
- 不要一次性写 10 个单元测试再实现
- 不要测私有函数、内部状态、实现细节

### 2. RED 必须真实失败

- 写完单元测试后，先跑，确认它失败
- 如果测试已经通过，说明测试没测到你要实现的行为，或者已经有实现了
- RED 的证据：失败的命令 + 失败信息

### 3. GREEN 用最小实现

- 只写让当前测试通过的最少代码
- 不要预判未来的测试
- 不要添加未请求的通用抽象

### 4. 重构留在最后

- 红-绿循环中不重构成瘾
- 当前 slice 所有业务测试都绿后，再集中做必要重构
- 重构后跑全套业务测试 + 单元测试

### 5. 单元测试不进入契约

- 单元测试文件可以改、可以删、可以合并
- 最终验收只认业务测试（CLI/E2E/API）
- 如果单元测试和业务测试冲突，业务测试优先
- **业务测试全绿只是最低门槛**：实现还必须符合 PRD 意图、tech-design 的模块/数据流/接口契约、UX HTML 的结构与行为。不能为了通过测试而写特判或阉割功能。

## 什么是好的单元测试

### ✅ 好的测试

- 测 public behavior，不测实现细节
- 测试名是句子：`user can create project with valid name`
- expected value 来自独立真理：spec、例子、手算结果
- 一个失败能精确定位问题
- 遵循 Arrange-Act-Assert 模式
- 一个概念一个断言/测试

### ❌ 反模式

- **实现耦合**：mock 内部协作对象、测私有方法、通过数据库查询验证
  - 信号：重构代码但行为没变，测试却失败
- **同义反复**：expected value 和实现算出来的方式一样
  - 信号：`expect(add(a,b)).toBe(a+b)`、手工 snapshot
- **水平切片**：一次写所有测试，再写所有实现
  - 信号：测试响应迟钝，对真实变化不敏感

### DAMP over DRY

生产代码中 DRY（Don't Repeat Yourself）通常是正确的。在测试中，**DAMP（Descriptive And Meaningful Phrases）** 更好。

每个测试应该独立可读，像一个 mini spec。共享 helper 可以提取，但不要为了让测试"不重复"而牺牲可读性。

```typescript
// DAMP：自包含、可读
it('rejects tasks with empty titles', () => {
  const input = { title: '', assignee: 'user-1' };
  expect(() => createTask(input)).toThrow('Title is required');
});

it('trims whitespace from titles', () => {
  const input = { title: '  Buy groceries  ', assignee: 'user-1' };
  const task = createTask(input);
  expect(task.title).toBe('Buy groceries');
});
```

### 测试替身优先级

使用最简单的测试替身，能用真实实现就不用 mock：

```
真实实现  → 最高置信度，能发现真实 bug
Fake     → 内存版依赖（如内存 DB）
Stub     → 返回固定数据，无行为
Mock     → 验证方法调用 —— 谨慎使用
```

**只在以下情况 mock：** 真实实现太慢、非确定性、或有不可控副作用（外部 API、发邮件）。过度 mock 会导致"测试通过但生产崩溃"。

### Arrange-Act-Assert

```typescript
it('marks overdue tasks when deadline has passed', () => {
  // Arrange
  const task = createTask({ title: 'Test', deadline: new Date('2025-01-01') });

  // Act
  const result = checkOverdue(task, new Date('2025-01-02'));

  // Assert
  expect(result.isOverdue).toBe(true);
});
```

### One Assertion Per Concept

```typescript
// Good：每个测试验证一个行为
it('rejects empty titles', () => { ... });
it('trims whitespace from titles', () => { ... });
it('enforces maximum title length', () => { ... });

// Bad：所有验证堆在一个测试里
it('validates titles correctly', () => {
  expect(() => createTask({ title: '' })).toThrow();
  expect(createTask({ title: '  hello  ' }).title).toBe('hello');
  expect(() => createTask({ title: 'a'.repeat(256) })).toThrow();
});
```

## Prove-It Pattern（修复 bug 时）

修复 bug 时，**不要先尝试修复**。先写一个能复现 bug 的测试，让它失败，再修复，让它通过。

```
Bug 报告到达
    │
    ▼
写一个展示 bug 的测试
    │
    ▼
测试 FAIL（确认 bug 存在）
    │
    ▼
实现修复
    │
    ▼
测试 PASS（证明修复有效）
    │
    ▼
跑全量业务测试（无回归）
```

这是把 bug 变成回归测试的最可靠方式。

## Seams 选择

TDD 的 seam 是 tech-design 阶段已经确定的边界：

- **CLI 命令**：一个子命令就是一个 seam
- **服务函数**：`projectService.create(name)`
- **数据访问层**：`db.createProject(project)`
- **工具/纯函数**：无 side effect 的计算函数
- **UI 组件事件处理函数**：如果测试 seam 是组件，事件处理是内部 seam

**规则**：只在 pre-agreed seams 上写单元测试。如果不确定 seam，先问 `/tech-design` 或人。

## 与 `/implementer` 的关系

```
/implementer
  │
  ▼ 自动 slice
slices.md
  │
  ▼ 对每个 slice
  ├─ 读业务测试（契约，只读）
  ├─ 用 /tdd 实现 slice 内代码
  │    ├─ RED：写单元测试，确认失败
  │    ├─ GREEN：最小实现
  │    └─ 重复直到业务测试绿
  └─ 跑全套业务测试回归
```

`/tdd` 不负责 commit、不负责 slice 拆分、不负责与人交互。它只负责：**给定一个 seam 和要满足的行为，用红-绿循环产出代码。**

## 汇报格式

`/tdd` 完成后返回给调用方（`/implementer`）：

```
- 实现的 seam 列表
- RED 证据：单元测试失败输出（1-3 行）
- GREEN 证据：单元测试通过输出（1-3 行）
- 业务测试结果：通过 / 失败
- 修改的文件
- concerns（如果有）
```

## 纪律

- **不写没有对应行为的单元测试**：每个单元测试必须对应业务测试或 REQ 中的一个具体行为
- **不保留已经失去意义的单元测试**：如果实现变了，旧的单元测试可以删
- **不_mock_业务测试**：业务测试必须走真实接口
- **不在 TDD 中修改业务测试**：业务测试是契约，只读
