# 参考来源：wizard

## 理念

循环工作流假设人"把握愿景、验证需求、审批设计、验收结果"——但大量真实工程步骤（配凭据、走第三方后台、一次性迁移）既不能 AI 代劳，也不属于任何 story 阶段。`/wizard` 把这些"只有人能做的步骤"固化成交互式 bash 脚本：人不用每次重讲流程，AI 也不用反复进同一对话。

## 借鉴的 reference 文件

- `reference/mattpocock/skills/engineering/wizard/SKILL.md`：wizard 的划定流程 → 映射路径 → 编写 → 验证四步法。
- `reference/mattpocock/skills/engineering/wizard/template.sh`：库 + 作者区结构（`STAGES` 标记线），原样搬移。

## 主要改动

- **frontmatter 惯例**：按本仓库补 `sources:`，去 `disable-model-invocation`。
- **正文骨架**：改写为我们的结构（何时调用/输入/输出/执行步骤/纪律/边界/示例）。
- **边界显性化**：新增"与相邻 skill 的边界"，明确与 `/bootstrap-workflow` 互补不重叠。
- `template.sh` 原样搬移，未改动（204 行，零依赖零测试）。

## 未来局部更新建议

- mattpocock 上游更新 `template.sh` 时，直接对比搬移文件并同步（库部分的一致性优先）。
- 若 `template.sh` 新增 helper，检查是否要在本 skill 的执行步骤 3 中补充说明。

## 改动记录

- 2026-08-16：新增 `/wizard`，收 mattpocock 第一梯队独立工具。
