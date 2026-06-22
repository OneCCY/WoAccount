# Budget Total Card + AI Config Restructure

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 1) Add total budget summary card at top of month view. 2) Restructure AI config into Supplier Management and Model Management sections, with click-to-activate supplier.

**Architecture:** Budget: add a summary card widget before the ListView in `_buildMonthView`. AI: split `LlmSettingsPage` into two clear sections, modify `_CapabilityConfigPage` to activate supplier on card tap instead of model selection.

**Tech Stack:** Flutter, Riverpod, GoRouter, Drift (SQLite), SharedPreferences

## Global Constraints

- All UI text must use `AppLocalizations` (l10n) — add keys to all 5 ARB files
- Follow existing code style: `context.colors.*`, `context.textStyles.*`, `AppDimensions.*`
- Currency formatting: `context.localeProvider.currency.formatAmount(amount, decimals: 0)`
- Each change must be committed with conventional commit format

---

### Task 1: Add l10n keys for new AI config sections

**Files:**
- Modify: `lib/l10n/app_en.arb`
- Modify: `lib/l10n/app_zh.arb`
- Modify: `lib/l10n/app_ja.arb`
- Modify: `lib/l10n/app_ko.arb`
- Modify: `lib/l10n/app_zh_TW.arb`

- [ ] Add 2 new l10n keys to all 5 ARB files:

**app_en.arb** (insert before closing `}`):
```
"llmSupplierManagement": "Supplier Management",
"llmModelManagement": "Model Management"
```

**app_zh.arb**:
```
"llmSupplierManagement": "服务商管理",
"llmModelManagement": "模型管理"
```

**app_ja.arb**:
```
"llmSupplierManagement": "サプライヤー管理",
"llmModelManagement": "モデル管理"
```

**app_ko.arb**:
```
"llmSupplierManagement": "공급업체 관리",
"llmModelManagement": "모델 관리"
```

**app_zh_TW.arb**:
```
"llmSupplierManagement": "服務商管理",
"llmModelManagement": "模型管理"
```

- [ ] Run `flutter gen-l10n` to regenerate localizations
- [ ] Commit: `feat(llm): add l10n keys for supplier/model management sections`

---

### Task 2: Restructure LlmSettingsPage — split into Supplier Management and Model Management sections

**Files:**
- Modify: `lib/features/settings/presentation/pages/llm_settings_page.dart`

The current `LlmSettingsPage.build()` has two sections:
1. Capability cards (text/vision/audio) — each opens `_CapabilityConfigPage`
2. Provider management list with Add/Edit/Delete/Test buttons

**Restructure to:**
1. **Model Management** section — capability cards, each opens `_CapabilityConfigPage` (unchanged behavior)
2. **Supplier Management** section — provider list with Add/Edit/Delete/Test (same content, different section label)

- [ ] In `LlmSettingsPage.build()`, change the section label from `l10n.llmProviderManagement` to `l10n.llmSupplierManagement`, and add a new section label `l10n.llmModelManagement` above the capability cards:

Replace the `children:` of the `Column` in `build()` (lines 300-328):

```dart
children: [
  // 1. 模型管理
  _sectionLabel(l10n.llmModelManagement),
  const SizedBox(height: 8),
  ...ModelCapability.values.map((cap) => _buildCapabilityCard(cap)),
  const SizedBox(height: 24),

  // 2. 服务商管理
  _sectionLabel(l10n.llmSupplierManagement),
  const SizedBox(height: 8),
  _providers.isEmpty ? _buildEmptyProviderHint() : _buildProviderList(),
  const SizedBox(height: 16),
  Center(
    child: OutlinedButton.icon(
      onPressed: _addProvider,
      icon: const Icon(Icons.add, size: 18),
      label: Text(l10n.llmAddProvider),
      style: OutlinedButton.styleFrom(
        foregroundColor: context.colors.primary,
        side: BorderSide(color: context.colors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    ),
  ),
  const SizedBox(height: 40),
],
```

- [ ] Commit: `refactor(llm): split settings page into model management and supplier management sections`

---

### Task 3: Modify _CapabilityConfigPage — click supplier card to activate

**Files:**
- Modify: `lib/features/settings/presentation/pages/llm_settings_page.dart`

**Current behavior:** In `_selectModel()` (line 707), selecting a model from the dropdown also calls `LlmConfigManager.setActiveProviderId(provider.id)`.

**New behavior:** Clicking anywhere on a supplier card (not just the model dropdown) should set that supplier as active. The model selection remains as-is but no longer triggers supplier activation.

- [ ] In `_CapabilityConfigPageState`, modify the `_buildProviderCard` method. Wrap the card's `Container` with a `GestureDetector` that calls a new `_activateProvider` method:

Replace the `_buildProviderCard` method (starting at line 931):

```dart
Widget _buildProviderCard(LlmProvider provider, {bool isActive = false}) {
  final preset = getPresetByKey(provider.providerKey);
  final entry = _entries[provider.id];
  final hasModels = entry != null && entry.fetchedModels.isNotEmpty;

  return GestureDetector(
    onTap: () => _activateProvider(provider),
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: isActive ? Border.all(color: context.colors.primary, width: 1.5) : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 服务商名称行 + 连接状态
            Row(
              children: [
                Text(preset?.icon ?? '🤖', style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    provider.name.isEmpty ? AppLocalizations.of(context)!.llmUnnamedProvider : provider.name,
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
                if (entry != null) _buildConnectionStatusIndicator(entry),
                if (isActive) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: context.colors.primarySurface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(AppLocalizations.of(context)!.llmInUse, style: AppTextStyles.caption.copyWith(color: context.colors.primary, fontSize: 11)),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // 模型选择下拉 + 获取按钮
            if (entry != null) ...[
              Row(
                children: [
                  Expanded(child: _buildModelDropdown(provider, entry, hasModels)),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: entry.isLoading ? null : () => _fetchModelsForProvider(provider),
                      icon: entry.isLoading
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.sync, size: 16),
                      label: Text(AppLocalizations.of(context)!.llmFetch, style: TextStyle(fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // 检测连接 + 自动检测间隔
              _buildConnectionCheckRow(provider, entry),
            ],
          ],
        ),
      ),
    ),
  );
}
```

- [ ] Add the `_activateProvider` method to `_CapabilityConfigPageState`:

```dart
Future<void> _activateProvider(LlmProvider provider) async {
  await LlmConfigManager.setActiveProviderId(provider.id);
  if (mounted) {
    setState(() {
      _activeId = provider.id;
    });
    AppToast.show(context, AppLocalizations.of(context)!.llmModelSet(
      widget.capability.getLocalizedLabel(AppLocalizations.of(context)!),
      provider.name,
      provider.getModelForCapability(widget.capability) ?? '',
    ));
  }
}
```

- [ ] In `_selectModel`, remove the `setActiveProviderId` call — model selection should no longer change the active provider. Keep only the model update:

```dart
Future<void> _selectModel(LlmProvider provider, String? model) async {
  if (model == null) return;

  final newModels = Map<String, ModelConfig>.from(provider.models);
  newModels[widget.capability.name] = ModelConfig(modelName: model);

  final updated = provider.copyWith(models: newModels);
  await LlmConfigManager.updateProvider(updated);

  if (mounted) {
    setState(() {
      _entries[provider.id]!.selectedModel = model;
      // 更新本地 provider 列表
      final idx = _providers.indexWhere((p) => p.id == provider.id);
      if (idx != -1) _providers[idx] = updated;
    });
    AppToast.show(context, AppLocalizations.of(context)!.llmModelSet(widget.capability.label, provider.name, model));
  }
}
```

- [ ] Commit: `feat(llm): click supplier card to activate, decouple model selection from provider activation`

---

### Task 4: Add total budget summary card to month view

**Files:**
- Modify: `lib/features/budget/presentation/pages/budget_page.dart`

**Design:** Add a gradient card at the top of `_buildMonthView` showing:
- Total budget amount (sum of all category budgets + any categoryId==null total budget)
- Total spent amount
- Progress bar (color-coded)
- Remaining amount

Position: Before the `ListView.builder`, as a fixed header in a `Column` with `Expanded` for the list.

- [ ] Modify `_buildMonthView` to include a summary card. Replace the method (lines 202-258):

```dart
Widget _buildMonthView(AppLocalizations l10n) {
  final budgetRepo = ref.read(budgetRepositoryProvider);
  final bookId = ref.watch(currentBookProvider);

  return FutureBuilder<List<BudgetProgress>>(
    future: budgetRepo.getBudgetProgress(bookId, _currentMonth.year, _currentMonth.month),
    builder: (context, snap) {
      if (snap.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator(color: context.colors.primary));
      }

      final allProgress = snap.data ?? [];
      // 过滤出有 categoryId 的预算（分类预算）
      final categoryProgresses = allProgress.where((p) => p.budget.categoryId != null).toList();

      if (categoryProgresses.isEmpty) {
        return _buildEmptyState(l10n);
      }

      // 计算总预算和总花费
      final totalBudget = categoryProgresses.fold<double>(0, (s, p) => s + p.budget.amount);
      final totalSpent = categoryProgresses.fold<double>(0, (s, p) => s + p.spent);
      // 也包含 categoryId==null 的总预算
      final globalBudgets = allProgress.where((p) => p.budget.categoryId == null).toList();
      final globalBudget = globalBudgets.fold<double>(0, (s, p) => s + p.budget.amount);

      // 按父分类分组
      final parentGroups = <int, List<BudgetProgress>>{};
      for (final p in categoryProgresses) {
        final cat = p.category;
        if (cat == null) continue;
        final pid = cat.parentId ?? cat.id;
        parentGroups.putIfAbsent(pid, () => []).add(p);
      }

      // 为每个父分类查询真实分类信息
      final catRepo = ref.read(categoryRepositoryProvider);
      return FutureBuilder<List<Category>>(
        future: catRepo.getTopLevel(),
        builder: (context, catSnap) {
          final allParents = catSnap.data ?? [];
          final parentMap = {for (final c in allParents) c.id: c};

          return Column(
            children: [
              // 总预算汇总卡片
              _buildMonthTotalCard(totalBudget, totalSpent, globalBudget, categoryProgresses.length, l10n),
              // 分类预算列表
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => setState(() {}),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: parentGroups.length,
                    itemBuilder: (context, index) {
                      final entry = parentGroups.entries.elementAt(index);
                      final parent = parentMap[entry.key];
                      if (parent == null) return const SizedBox.shrink();
                      final children = entry.value;
                      final groupBudget = children.fold<double>(0, (s, p) => s + p.budget.amount);
                      final groupSpent = children.fold<double>(0, (s, p) => s + p.spent);
                      return _buildParentItem(parent, groupBudget, groupSpent, l10n);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
```

- [ ] Add the `_buildMonthTotalCard` method after `_buildMonthView`:

```dart
Widget _buildMonthTotalCard(double totalBudget, double totalSpent, double globalBudget, int categoryCount, AppLocalizations l10n) {
  // 如果有全局总预算且大于分类预算之和，用全局总预算作为总量
  final effectiveBudget = globalBudget > totalBudget ? globalBudget : totalBudget;
  final percentage = effectiveBudget > 0 ? (totalSpent / effectiveBudget * 100) : 0.0;
  final barColor = percentage > 90
      ? context.colors.error
      : percentage > 70
          ? context.colors.warning
          : context.colors.success;
  final remaining = effectiveBudget - totalSpent;

  return Padding(
    padding: const EdgeInsets.fromLTRB(AppDimensions.md, 8, AppDimensions.md, 4),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colors.primary.withValues(alpha: 0.08),
            context.colors.primary.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: context.colors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              Text(l10n.budgetMonthlyTotal, style: context.textStyles.footnote.copyWith(color: context.colors.primary)),
              const Spacer(),
              Text(l10n.budgetCategoryCount(categoryCount.toString()),
                style: context.textStyles.caption.copyWith(color: context.colors.textTertiary)),
            ],
          ),
          const SizedBox(height: 10),
          // 金额行：已花费 / 总预算
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                context.localeProvider.currency.formatAmount(totalSpent, decimals: 0),
                style: context.textStyles.amountLarge.copyWith(
                  color: totalSpent > effectiveBudget ? context.colors.error : context.colors.primaryDark,
                ),
              ),
              Text(
                ' / ${context.localeProvider.currency.formatAmount(effectiveBudget, decimals: 0)}',
                style: context.textStyles.body.copyWith(color: context.colors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 进度条
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0, 1),
              minHeight: 8,
              backgroundColor: context.colors.surfaceSecondary,
              valueColor: AlwaysStoppedAnimation(barColor),
            ),
          ),
          const SizedBox(height: 8),
          // 底部信息行
          Row(
            children: [
              Text(
                l10n.budgetUsedPercent(percentage.toStringAsFixed(0)),
                style: context.textStyles.caption.copyWith(color: barColor),
              ),
              const Spacer(),
              Text(
                l10n.budgetRemaining(context.localeProvider.currency.formatAmount(remaining, decimals: 0)),
                style: context.textStyles.caption.copyWith(
                  color: remaining < 0 ? context.colors.error : context.colors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
```

- [ ] Commit: `feat(budget): add total budget summary card to month view`

---

### Task 5: Build and verify on device

- [ ] Run `flutter analyze` to check for errors
- [ ] Run `flutter run` on real device to verify:
  - Budget page: month view shows total card at top with correct amounts
  - AI config: main page shows "模型管理" and "服务商管理" sections
  - AI config: capability config page — clicking a supplier card activates it (sets as in-use)
  - AI config: selecting a model from dropdown no longer changes the active provider
- [ ] Commit any fixes: `fix: address build issues from budget/AI config changes`
