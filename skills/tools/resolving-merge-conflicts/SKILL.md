---
name: resolving-merge-conflicts
description: 解决进行中的 git merge/rebase 冲突：先找每个冲突的 primary sources（提交信息/PR/issue，理解双方意图），逐 hunk 尽量保留双方意图，跑项目自动化检查，收尾提交。绝不 --abort。独立触发，不绑定 story。
sources:
  - reference/mattpocock/skills/engineering/resolving-merge-conflicts/SKILL.md
---

# resolving-merge-conflicts

## 何时调用

- 正在 git merge / rebase 中，出现冲突文件。
- 用户说"帮我解决这个冲突"、"merge 冲突"。

**不调用的情况**：

- 不是冲突，而是别的 bug → 走 `/bug`。
- 想做代码审查 → 走 `/review`。

## 输入

无参数。以当前工作区的 merge/rebase 状态为输入。

## 输出

冲突解决并提交后的干净状态；收尾 commit（merge 或 rebase 完成）。

## 执行步骤

1. **看当前状态**：merge/rebase 到哪一步了。检查 git history 与冲突文件。
2. **找每个冲突的 primary sources**：深入理解每处改动为什么存在、原始意图是什么。读 commit messages、查 PR、查原始 issue/ticket。
3. **逐 hunk 解决**：能保留双方意图就保留。不兼容时，选贴合 merge 目标的一方并记录 trade-off。**不要发明新行为。总是解决，绝不 `--abort`。**
4. **发现并运行项目的自动化检查**：通常是 typecheck → tests → format。修任何被 merge 弄坏的。
5. **收尾**：stage 全部并提交。若是 rebase，continue 到所有 commit 重放完成。

## 纪律

1. **意图优先**：每个冲突先理解双方意图，再动手。
2. **绝不 `--abort`**：abort 是最后手段之外的选项；冲突总是可解的。
3. **不发明行为**：合并不引入新逻辑。
4. **验证收尾**：提交前跑自动化检查，修好 merge 弄坏的东西。

## 与相邻 skill 的边界

| Skill | 负责 | 不负责 |
|---|---|---|
| `/resolving-merge-conflicts` | merge/rebase 冲突解决 | 非冲突 bug |
| `/bug` | 单 bug 人机协同（根因/分类/修/补测试） | git 冲突 |
| `/review` | 提交前审查 | 冲突解决 |

## 示例

```bash
# 处于 git merge 中，出现冲突：
# 直接调用本 skill，按 5 步解决 → 提交 → merge 完成
```
