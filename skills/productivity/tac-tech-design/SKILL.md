---
name: tac-tech-design
description: 对 PRD 稳定块进行对抗式技术方案设计：通过拷问澄清模块边界、数据流、接口契约与测试 seams，输出 tech-design.md。
disable-model-invocation: true
sources:
  - reference/gstack/plan-eng-review/SKILL.md
  - reference/mattpocock/skills/engineering/codebase-design/SKILL.md
  - reference/mattpocock/skills/engineering/grill-with-docs/SKILL.md
  - reference/mattpocock/skills/engineering/domain-modeling/SKILL.md
  - workflow/design/test-as-contract-workflow.md
---

# tac-tech-design

## 何时调用

PRD 已有明确稳定块，但进入 `/tac-crystallize` 之前还需要把"用户语言"翻译成"系统语言"时。用户说"设计技术方案"、"/tac-tech-design"时。

本 skill 不替代 PRD，而是承接 PRD。如果 PRD 本身还在大动，先回流 `/tac-to-prd`。

## 输入

- `.aiassist/stories/<id>/prd.md`
- `.aiassist/stories/<id>/workflow-state.yaml`
- 现有代码库（了解当前架构、领域词汇、已有 seams）
- `.aiassist/global/architecture.md`（如有）
- `.aiassist/global/STANDARDS.md`（如有）

## 输出

- `.aiassist/stories/<id>/tech-design.md`

## 执行步骤

### 1. 读取上下文

读 PRD，识别所有稳定块和已标注的模块边界/测试 seams。快速扫一遍现有代码，了解：
- 项目使用的语言/框架
- 已有模块/服务分层
- 已有设计模式（错误处理、状态管理、持久化等）

### 2. 第一轮对抗式提问

不要直接给方案。先向用户抛出 4-8 个尖锐问题，覆盖以下维度：

#### 模块与边界
- 这个需求会穿透哪些已有模块？会新建模块吗？
- 每个模块的职责是否单一？有没有既有模块要"被迫"了解太多？
- 跨模块调用是同步还是异步？调用失败怎么办？

#### 数据流
- 用户操作后，数据从哪进入系统，经过哪些转换，写到哪里？
- 有哪些副作用（写库、发事件、调外部 API、改文件）？
- 状态是集中管理还是分散到各模块？

#### 接口契约
- 模块之间交换的数据结构长什么样？
- 错误怎么表示？调用方如何区分"业务错误"和"系统错误"？
- 有没有隐式依赖（全局状态、顺序假设、副作用时机）？

#### 测试 seams
- 每个稳定块能在哪个 seam 上被独立测试？
- 哪些依赖必须 mock？哪些应该保留真实实现？
- 是否有必须 E2E 才能验证的用户流程？

#### 复杂度挑战（借鉴 gstack plan-eng-review）
- 如果实现会触碰 8+ 文件或引入 2+ 新服务/类，提出更小的替代方案。
- 是否有现成库/框架能力可以复用，而不是自己写？
- 这个方案是不是过度设计？最简可行方案是什么？

#### 风险与回退
- 哪些技术假设如果错了，会导致大幅返工？
- 这些假设在一挡内能不能快速验证（spike、原型、查文档）？

### 3. 根据用户回答继续追问

- 把模糊词汇钉死："服务"具体指什么？"状态"存在哪？"事件"谁消费？
- 用边界 case 测试设计：如果这一步失败、如果数据为空、如果并发执行，方案还成立吗？
- 把口头方案映射到具体模块/接口："你刚才说的 X，是 A 模块直接调用 B，还是通过 C 中转？"

### 4. 综合并起草 `tech-design.md`

当方案稳定到"可以画模块图、可以切 seams"时，使用 `templates/story/tech-design.md.template` 输出。

### 5. 提交给用户审查

- "这是根据刚才讨论整理的技术方案。模块边界、接口契约、seams 是否准确？"
- 用户修改后定稿。

### 6. 更新 workflow-state

标记 TECH-DESIGN 阶段完成，下一阶段为 CRYSTALLIZE。

## 纪律

- **不写代码**：只到接口/模块/数据流层面，不写文件路径或具体实现。
- **不替代 PRD**：如果讨论中发现需求本身 unclear，回流 `/tac-to-prd`。
- **对抗式但不抬杠**：目的是暴露盲区，不是证明用户错了。
- ** Seam 是测试的出生地**：每个稳定块至少要有一个清晰的测试 seam。
- **跨模块必须有显式契约**：输入、输出、错误、副作用，四要素缺一不可。

## 与参考项目的差异

- gstack `plan-eng-review`：给我们工程审查的问题清单和复杂度检查。
- mattpocock `codebase-design`：给我们 deep modules、seams、interfaces 的统一词汇。
- mattpocock `grill-with-docs` / `domain-modeling`：给我们对抗式访谈和术语挑战方法。
- 核心差异：把技术方案设计成进入 REQ 前的独立一挡阶段，输出物直接服务测试契约。
