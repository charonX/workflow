---
name: domain-model
description: 维护项目的领域词汇表（CONTEXT.md）和业务实体关系。在术语冲突、新增业务概念、或技术方案设计前统一语言时触发。
sources:
  - reference/mattpocock/skills/engineering/domain-modeling/SKILL.md
  - reference/mattpocock/skills/deprecated/ubiquitous-language/SKILL.md
  - reference/mattpocock/skills/in-progress/wayfinder/SKILL.md
---

# domain-model

## 何时调用

- 用户说"更新领域模型"、"/domain-model"、"统一术语"。
- 技术方案设计前（`complex` story 走 `/tech-design`）发现 PRD 中出现新术语或与 `CONTEXT.md` 冲突。
- `/reflect` 阶段发现本次 story 引入了新业务概念或术语冲突。
- `/review --cover=prd` 发现术语不一致。

## 输入

- `.aiassist/global/CONTEXT.md`（已有领域词汇表，可能没有）
- `.aiassist/stories/<id>/prd.md`（当前 story 的术语；§10 技术方案中的实体名）
- 项目源码中的实体/类型/模块名（可选）

## 输出

- 更新后的 `.aiassist/global/CONTEXT.md`
- 可选：`.aiassist/global/business-capabilities.md` 中的实体列（与 `/crystallize` 协作）

## 核心原则

### CONTEXT.md 只包含领域语言

- **只放业务概念**：实体、行为、状态、角色、业务规则
- **不放实现细节**：具体类名、API 路径、数据库字段、框架选择
- **代码映射是例外**：可以在"代码映射"列标注实体对应的主要文件，但定义本身必须是业务语言

### 主动挑战模糊语言

- 同一个词是否在不同地方代表不同概念？
- 不同词是否其实指同一个概念？
- 是否有过度泛化的词（如 "account" 既指 User 又指 Customer）？

### 术语即时沉淀

- 会话中一旦确定某个术语，立即更新 `CONTEXT.md`
- 不批量累积，避免遗忘上下文

## 执行步骤

1. **读取现有 `CONTEXT.md`**
   - 如果不存在，创建空模板。

2. **扫描当前 story 的术语**
   - 读取 `prd.md`（含 §10 技术方案）。
   - 提取所有名词、动词、状态词。
   - 标记疑似业务概念的词汇。

3. **对比现有词汇表**
   - 新术语 → 提议定义
   - 冲突术语 → 标注冲突并给出统一建议
   - 已存在术语 → 检查用法是否一致

4. **与用户确认（如需要）**
   - 如果有冲突或不确定的术语，一次性列出选项请用户选择。
   - 如果术语清晰且无冲突，直接更新。

5. **更新 `CONTEXT.md`**
   - 使用统一格式（见下）。
   - 在变更记录中注明来源 story。

6. **同步到 `business-capabilities.md`（可选）**
   - 如果发现新的核心实体，提示 `/crystallize` 或用户更新能力地图。

## CONTEXT.md 格式

```markdown
# 领域词汇表 — <项目名称>

> 本文件由 `/domain-model` 维护。
> 所有 skill 在读写代码/文档时，优先使用本文件的术语。
> 新增术语需经 `/domain-model` 确认。

---

## 核心实体

| 术语 | 英文 | 定义 | 代码映射 | 别名（禁止使用） |
|------|------|------|----------|----------------|
| 用户 | User | 系统的注册账户持有者 | `src/models/User.ts` | 会员、客户 |
| 项目 | Project | 用户创建的独立工作空间 | `src/models/Project.ts` | 工程、workspace |
| 任务 | Task | 项目内的可执行单元 | `src/models/Task.ts` | 事项、todo |

## 业务概念

| 术语 | 定义 | 相关实体 | 使用场景 |
|------|------|----------|----------|
| 归档（回流） | 进行中 story 回流重做时，把被推翻的承诺层产物移入 `archive/attempt-N/` | Story | 回流机制 |
| 完成清理 | story 完成后（`status: completed`），`/reflect` 将整个 story 目录提交删除，进 git 历史 | Story | 收尾 |
| 签核 | 契约锁定：断言 expected 可 trace 到规格锚点；高风险项人确认 | Signoff | 门 1 / 门 2 |
| 能力 | 系统对外提供的独立业务功能 | Capability | 测试组织 |

## 状态与生命周期

| 术语 | 定义 | 所属实体 | 状态转换 |
|------|------|----------|----------|
| 待实现 | Story 已通过断言签核，等待 /implementer | Story | 待实现 → 实现中 → 已完成 |
| 已签核 | 断言已通过 AI 自检锁定（expected 可 trace；升级项人已确认） | Signoff | — |

## 命名约定

- 数据库表：复数小写 `users`, `projects`
- TypeScript 接口：PascalCase `User`, `Project`
- API 端点：kebab-case `/api/v1/users`
- CLI 命令：kebab-case `project create`, `user list`

## 变更记录

| 日期 | 变更 | 触发 story |
|------|------|------------|
| 2026-07-01 | 新增"任务"实体 | 2026-06-28-task-management |
| 2026-07-05 | "项目"别名去除"workspace" | /domain-model 术语审查 |
```

## 与其他 skill 的关系

- `/to-prd`：PRD 中首次出现新术语时，可调用 `/domain-model` 沉淀。
- `/tech-design`：设计前读取 `CONTEXT.md` 统一术语；发现新术语时回流到 `/domain-model`（`complex` story 时）。
- `/crystallize`：根据 `CONTEXT.md` 为 REQ 选择规范术语。
- `/test-author`：使用 `CONTEXT.md` 中的术语统一测试命名。
- `/implementer`：使用 `CONTEXT.md` 中的术语命名代码实体。
- `/reflect`：story 结束后如发现术语演化，更新 `CONTEXT.md`。

## 纪律

- **不做实现决策**：`CONTEXT.md` 是词汇表，不是技术方案（`prd.md` §10）。
- **不复制 PRD**：只提炼术语和关系，不复制需求细节。
- **保持 opinionated**：同一概念有多个词时，选一个规范词，其他列为禁用别名。
- **冲突必须解决**：发现术语冲突时不能放过，必须统一。
