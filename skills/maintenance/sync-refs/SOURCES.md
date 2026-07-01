# 参考来源

这个 skill 是 workflow 维护工具，不借鉴 reference 项目，而是服务于"检查 reference 变更 → 吸收到 workflow"的维护流程。

## 依赖的内部工具

- `scripts/sync-refs.sh` — 机械脚本（拉取 + diff + 报告生成）
- `.aiassist/global/sync-refs-state.json` — 持久化同步时间戳

## 改动记录

- 2026-07-01：新建
  - 实现 reference 定期同步工作流
  - 三步法：脚本生成报告 → 人工逐项判断 → 吸收/跳过
  - 配合 `scripts/sync-refs.sh` 使用
