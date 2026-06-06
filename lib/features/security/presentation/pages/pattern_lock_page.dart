import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 图案解锁页面
/// 支持设置模式和验证模式
class PatternLockPage extends StatefulWidget {
  final String mode; // 'setup' or 'verify'

  const PatternLockPage({super.key, required this.mode});

  @override
  State<PatternLockPage> createState() => _PatternLockPageState();
}

class _PatternLockPageState extends State<PatternLockPage> {
  List<int> _currentPattern = [];
  bool _isConfirming = false;
  String _error = '';

  @override
  Widget build(BuildContext context) {
    final isSetup = widget.mode == 'setup';
    final title = isSetup
        ? (_isConfirming ? '请再次绘制图案确认' : '绘制解锁图案')
        : '请绘制图案解锁';
    final subtitle = isSetup
        ? (_isConfirming ? '请绘制与刚才相同的图案' : '连接至少4个点')
        : '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isSetup ? '设置图案锁' : '图案解锁'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 1),

            // 标题
            Text(title, style: AppTextStyles.h3.copyWith(fontSize: 18)),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(subtitle, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
            ],
            const SizedBox(height: 40),

            // 图案绘制区域
            _buildPatternGrid(),

            const SizedBox(height: 16),

            // 错误提示
            if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  _error,
                  style: AppTextStyles.caption.copyWith(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
              ),

            const Spacer(flex: 2),

            // 重置按钮
            if (isSetup)
              TextButton(
                onPressed: () {
                  setState(() {
                    _currentPattern = [];
                    _isConfirming = false;
                    _error = '';
                  });
                },
                child: Text('重新绘制', style: AppTextStyles.body.copyWith(color: AppColors.primary)),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternGrid() {
    return SizedBox(
      width: 240,
      height: 240,
      child: _PatternGridWidget(
        onPatternComplete: _onPatternComplete,
      ),
    );
  }

  void _onPatternComplete(List<int> pattern) {
    if (pattern.length < 4) {
      setState(() => _error = '请至少连接4个点');
      HapticFeedback.heavyImpact();
      return;
    }

    setState(() => _error = '');

    if (widget.mode == 'setup') {
      if (!_isConfirming) {
        // 第一次绘制
        setState(() {
          _currentPattern = List.from(pattern);
          _isConfirming = true;
        });
      } else {
        // 确认绘制
        if (_listEquals(pattern, _currentPattern)) {
          // 两次一致，保存
          _savePattern(pattern);
        } else {
          setState(() {
            _error = '两次图案不一致，请重新绘制';
            _currentPattern = [];
            _isConfirming = false;
          });
          HapticFeedback.heavyImpact();
        }
      }
    } else {
      // 验证模式
      _verifyPattern(pattern);
    }
  }

  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Future<void> _savePattern(List<int> pattern) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lock_pattern', pattern.join(','));
    await prefs.setBool('lock_enabled', true);
    await prefs.setString('lock_type', 'pattern');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('图案设置成功'), duration: Duration(milliseconds: 500)),
      );
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _verifyPattern(List<int> pattern) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPattern = prefs.getString('lock_pattern') ?? '';

    if (pattern.join(',') == savedPattern) {
      if (mounted) Navigator.of(context).pop(true);
    } else {
      setState(() {
        _error = '图案错误，请重试';
        _currentPattern = [];
      });
      HapticFeedback.heavyImpact();
    }
  }
}

/// 图案绘制网格组件
class _PatternGridWidget extends StatefulWidget {
  final Function(List<int>) onPatternComplete;

  const _PatternGridWidget({required this.onPatternComplete});

  @override
  State<_PatternGridWidget> createState() => _PatternGridWidgetState();
}

class _PatternGridWidgetState extends State<_PatternGridWidget> {
  List<int> _selectedDots = [];
  Offset? _currentPosition;
  bool _isDrawing = false;

  static const double _gridSize = 240;
  static const int _cols = 3;
  static const int _rows = 3;
  static const double _dotRadius = 12;
  static const double _cellSize = _gridSize / _cols;

  /// 获取每个圆点的中心位置
  Offset _getDotCenter(int index) {
    final row = index ~/ _cols;
    final col = index % _cols;
    return Offset(
      col * _cellSize + _cellSize / 2,
      row * _cellSize + _cellSize / 2,
    );
  }

  /// 根据触摸位置找到最近的圆点
  int? _findNearestDot(Offset position) {
    for (int i = 0; i < _cols * _rows; i++) {
      final center = _getDotCenter(i);
      final distance = (position - center).distance;
      if (distance < _cellSize * 0.45) {
        return i;
      }
    }
    return null;
  }

  void _onPanStart(DragStartDetails details) {
    final dotIndex = _findNearestDot(details.localPosition);
    if (dotIndex != null) {
      setState(() {
        _selectedDots = [dotIndex];
        _currentPosition = details.localPosition;
        _isDrawing = true;
      });
      HapticFeedback.lightImpact();
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDrawing) return;

    final dotIndex = _findNearestDot(details.localPosition);
    if (dotIndex != null && !_selectedDots.contains(dotIndex)) {
      setState(() {
        _selectedDots.add(dotIndex);
        _currentPosition = details.localPosition;
      });
      HapticFeedback.lightImpact();
    } else {
      setState(() => _currentPosition = details.localPosition);
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isDrawing) {
      widget.onPatternComplete(List.from(_selectedDots));
      setState(() {
        _isDrawing = false;
        _currentPosition = null;
        // 延迟清除，让用户看到结果
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) setState(() => _selectedDots = []);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: CustomPaint(
        size: const Size(_gridSize, _gridSize),
        painter: _PatternPainter(
          selectedDots: _selectedDots,
          currentPosition: _currentPosition,
          getDotCenter: _getDotCenter,
          isDrawing: _isDrawing,
        ),
      ),
    );
  }
}

/// 图案绘制画笔
class _PatternPainter extends CustomPainter {
  final List<int> selectedDots;
  final Offset? currentPosition;
  final Offset Function(int) getDotCenter;
  final bool isDrawing;

  _PatternPainter({
    required this.selectedDots,
    this.currentPosition,
    required this.getDotCenter,
    required this.isDrawing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const int totalDots = 9;

    // 画所有圆点
    for (int i = 0; i < totalDots; i++) {
      final center = getDotCenter(i);
      final isSelected = selectedDots.contains(i);

      // 外圈
      final outerPaint = Paint()
        ..color = isSelected ? AppColors.primary : AppColors.textTertiary.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(center, _PatternGridWidgetState._dotRadius, outerPaint);

      // 内圈（选中时填充）
      if (isSelected) {
        final innerPaint = Paint()
          ..color = AppColors.primary
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, 6, innerPaint);
      }
    }

    // 画连接线
    if (selectedDots.length >= 2) {
      final linePaint = Paint()
        ..color = AppColors.primary.withValues(alpha: 0.6)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < selectedDots.length - 1; i++) {
        final start = getDotCenter(selectedDots[i]);
        final end = getDotCenter(selectedDots[i + 1]);
        canvas.drawLine(start, end, linePaint);
      }

      // 画到当前位置的线
      if (isDrawing && currentPosition != null) {
        final lastDot = getDotCenter(selectedDots.last);
        canvas.drawLine(lastDot, currentPosition!, linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PatternPainter oldDelegate) {
    return oldDelegate.selectedDots != selectedDots ||
        oldDelegate.currentPosition != currentPosition ||
        oldDelegate.isDrawing != isDrawing;
  }
}
