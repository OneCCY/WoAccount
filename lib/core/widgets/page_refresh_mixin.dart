import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes/app_router.dart';

/// 页面数据自动刷新 Mixin
///
/// 适用于 GoRouter ShellRoute 中的标签页和普通页面：
/// - 标签切换回当前页时自动刷新
/// - 从子页面返回时自动刷新
/// - 首次进入页面时自动刷新
///
/// 用法：
/// ```dart
/// class _MyPageState extends State<MyPage> with PageRefreshMixin {
///   @override
///   String get routePath => '/my-route';
///
///   @override
///   void initState() {
///     super.initState();
///     _loadData(); // 首次加载
///   }
///
///   @override
///   void onRefresh() => _loadData(); // 路由激活时刷新
/// }
/// ```
mixin PageRefreshMixin<T extends StatefulWidget> on State<T> implements RouteAware {
  /// 当前页面的路由路径（用于标签页切换检测）
  String get routePath;

  /// 路由激活时的回调（标签切换 / 子页面返回 / 首次进入）
  void onRefresh();

  String? _currentRoutePath;
  bool _subscribed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = GoRouterState.of(context);
    final path = route.uri.path;

    // 订阅路由观察者（确保只订阅一次）
    if (!_subscribed) {
      routeObserver.subscribe(this, ModalRoute.of(context)!);
      _subscribed = true;
    }

    // 标签页切换检测：路由路径变化时刷新
    if (_currentRoutePath != path) {
      _currentRoutePath = path;
      // 避免与 initState 首次加载重复
      if (_currentRoutePath != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) onRefresh();
        });
      }
    }
  }

  /// 从子页面返回时刷新
  @override
  void didPopNext() {
    onRefresh();
  }

  @override
  void didPush() {}

  @override
  void didPop() {}

  @override
  void didPushNext() {}

  @override
  void dispose() {
    if (_subscribed) {
      routeObserver.unsubscribe(this);
    }
    super.dispose();
  }
}
