# 参考来源：resolving-merge-conflicts

## 理念

git 冲突解决是纯正交的日常工程操作，与 story 循环毫无关系。mattpocock 的版本哲学很好：冲突不是"删掉别人的"而是"理解双方意图后合流"——先找 primary sources（commit/PR/issue），尽量 preserve both intents，**绝不 `--abort`**。收进来作为独立工具。

## 借鉴的 reference 文件

- `reference/mattpocock/skills/engineering/resolving-merge-conflicts/SKILL.md`：5 步流程（看状态 → 找 primary sources → 逐 hunk 解决 → 跑自动化检查 → 收尾提交）。

## 主要改动

- **frontmatter 惯例**：按本仓库补 `sources:`。
- **正文骨架**：改写为我们的结构（何时调用/输入/输出/执行步骤/纪律/边界/示例）。
- 核心 5 步流程保持原文（这是它的全部价值）。

## 未来局部更新建议

- mattpocock 上游更新时，逐条对比 5 步流程是否有增补（如新增 check 顺序或 rebase 细节）。

## 改动记录

- 2026-08-16：新增 `/resolving-merge-conflicts`，收 mattpocock 第一梯队独立工具。
