# ADR 0004: 合并 PRD 与 tech-design 为单一 spec 文档

## Status

Accepted（2026-08-06）

## Context

v0.17 之前，工作流把产品意图（`prd.md`）与技术方案（`tech-design.md`）分为两个文档、两个阶段（PRD → TECH-DESIGN）。实际使用暴露三类问题：

1. **文档冗余与漂移**。`prd.md` 第 10 节"实现决策"、第 11 节"测试决策"本身就含技术内容，与 `tech-design.md` 重叠；`/tech-design` 还专门有"反向同步 PRD"步骤来修补两个文档失步。
2. **simple story 的仪式成本**。技术路径显然时，独立 tech-design 阶段不新增信息，只多一个 `/review --stage=tech` 门和一份要维护的文档。单人场景（OPC）下用户对长输出不细读、只关心决策点，文档层越薄越好。
3. **mattpocock 的合并先例**。mattpocock 以单一 `spec`（= PRD 概念）承载 Problem/Solution/User Stories + Implementation Decisions + Testing Decisions，技术设计不设独立文档阶段，流程更薄。

但"测试即契约"引擎有一堵承重墙不能拆：**结晶前必须定义 seams/接口契约**——`/crystallize` 用它们给 REQ 挂测试类型与 `interface_contract`，跨模块 REQ 必须显式接口契约；且复杂 story 的技术取舍需要一次独立的对抗式检查，防止把不可实现的块锁成 REQ。

## Decision

1. **合并为一个文档 `prd.md`（概念上即 spec）**。原 `tech-design.md` 内容折入 `prd.md`：§10 技术方案（设计目标 / 模块与边界 / 数据流 / 接口契约 / 关键决策 / 风险与回流点 / 安全·性能·可观测性）、§11 测试决策（覆盖接缝 CLI 优先 + 测试策略与先例）。`tech-design.md` 产物文件与模板删除，不再生成。
2. **`/tech-design` 改为条件深潜**。仅当 PRD §9 复杂度分级为 `complex`、或 `/crystallize` 技术可行性预演发现 seam 缺失时调用；输出写入 `prd.md` §10，反向同步 §4/§5 稳定/移动块。`simple` story 由 `/to-prd` 直接填 §10 高层 + §11 seams，跳过本 skill。
3. **阶段机 `TECH-DESIGN` 保留但变条件**。`simple` story 不进入；`complex` story 在结晶前必经。同时保留为回流目标——story 回流映射"技术方案层 → TECH-DESIGN"仍有效，语义 = 重做 `prd.md` §10。
4. **`/review --stage=tech` 并入 `--stage=prd`**。技术方案审查属于合并后 PRD 审查的一部分；`--stage=code` 不变。
5. **文件名保留 `prd.md`**，不改成 `spec.md`，避免波及所有路径引用；回流锚点仍是"PRD 问题陈述"。

## Consequences

### 正面

- **文档减半、漂移消除**。不再需要"反向同步 PRD"补丁；simple story 少一个阶段、一个 review 门。
- **问答价值保留**。对抗式技术访谈（用户实际看重的部分）在 complex 路径完整保留，只是输出落点从独立文档改为 `prd.md` §10。
- **承重墙不动**。seams/接口契约仍在结晶前定义（`/to-prd` §11 或 `/tech-design` §10），`/crystallize` 的 `interface_contract` 链路闭环不受影响。

### 代价

- **复杂 story 的单一文档会更长**。用 §10/§11 的子结构分区缓解；`complex` story 仍享受完整对抗式审查。
- **旧 story 迁移成本**。已存在的 `tech-design.md` 不删除（只读历史产物）；`/tech-design` 遇到旧 story 时先读再迁移到 `prd.md` §10。
- **历史 ADR（0001-0003）中的 `tech-design.md` 表述不再更新**，它们是历史记录。

## 替代方案

- **完全保留两文档两阶段**：文档漂移与 simple 仪式成本持续存在，否决。
- **重命名 `prd.md` → `spec.md`**：改动面过大、与"简化"目标相悖，否决。
- **只合并文档、不保留条件深潜**：complex story 的对抗式技术审查会被稀释，破坏承重墙，否决。

## 相关文件

- `templates/story/prd.md.template`（§9-14 合并后的结构）
- `skills/productivity/to-prd/SKILL.md`（复杂度分级 → 结晶路径）
- `skills/productivity/tech-design/SKILL.md`（条件深潜）
- `skills/engineering/crystallize/SKILL.md`（只读 `prd.md` §10/§11）
- `skills/productivity/review/SKILL.md`（`stage=tech` 并入 `stage=prd`）
- 参考：mattpocock `to-spec`（Implementation Decisions + Testing Decisions 单一 spec）
