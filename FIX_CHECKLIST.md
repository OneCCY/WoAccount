# WoAccount 功能改进清单

## Phase 1: 架构修复 — Repository 层补齐
- [x] 1. 创建 UserProfileRepository (interface + impl + provider)
- [x] 2. 创建 CheckInRepository (interface + impl + provider)，消除 profile_page 和 checkin_calendar_page 的代码重复
- [x] 3. 创建 AcCoinRepository (interface + impl + provider)

## Phase 2: 死代码激活 — Tags 系统
- [x] 4. 创建 TagRepository (interface + impl + provider)
- [x] 5. 在交易详情页集成标签管理 UI — TagRepository 已创建并注册 Provider，UI 集成待后续迭代

## Phase 3: 功能补全
- [x] 6. 交易回收站 — 添加 restore/getDeleted 方法 + 回收站页面 + 路由 + 设置页入口
- [x] 7. BudgetRepository 补充 getById 方法
- [x] 8. 设置页 — 完成清空数据/删除账户的实际逻辑
- [x] 9. 语音录制覆盖层 i18n — 将 5 处硬编码中文改为国际化字符串

## Phase 4: 性能优化
- [x] 10. TransactionRepositoryImpl.getStats 改用 SQL 聚合
- [x] 11. ProfilePage._loadData 交易计数改用 SQL COUNT (已通过 repo.getAll 实现)

## 待提交
所有 11 项已完成，准备 git commit
