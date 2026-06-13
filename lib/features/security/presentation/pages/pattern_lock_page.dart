import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/toast.dart';

/// 图案解锁页面
/// 支持设置模式和验证模式
class PatternLockPage extends StatefulWidget {
  final String mode; // 'setup' or 'verify'
  final VoidCallback? onAuthenticated;

  const PatternLockPage({super.key, required this.mode, this.onAuthenticated});

  @override
  State<PatternLockPage> createState() => _PatternLockPageState();
}

class _PatternLockPageState extends State<PatternLockPage> {
  List<int> _currentPattern = [];
  bool _isConfirming = false;
  String _error = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSetup = widget.mode == 'setup';
    final title = isSetup
        ? (_isConfirming ? l10n.securityConfirmPattern : l10n.securityDrawPattern)
        : l10n.securityDrawToUnlock;
    final subtitle = isSetup ? (_isConfirming ? l10n.securityConfirmPatternHint : l10n.securityPatternHint) : '';

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: isSetup
          ? AppBar(
              title: Text(l10n.securitySetPatternLock),
              backgroundColor: Colors.transparent,
              elevation: 0,
            )
          : null,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isSetup)
                SizedBox(height: MediaQuery.of(context).padding.top),

              // 标题
              Text(title, style: context.textStyles.h3.copyWith(fontSize: 18)),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: context.textStyles.caption.copyWith(
                    color: context.colors.textTertiary,
                  ),
                ),
              ],
              const SizedBox(height: 40),

              // 图案绘制区域（居中）
              _buildPatternGrid(),

              const SizedBox(height: 24),

              // 错误提示
              if (_error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    _error,
                    style: context.textStyles.caption.copyWith(
                      color: context.colors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 40),

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
                  child: Text(
                    l10n.securityRedraw,
                    style: context.textStyles.body.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                ),
            ],
          ),
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
        colors: context.colors,
      ),
    );
  }

  void _onPatternComplete(List<int> pattern) {
    if (pattern.length < 4) {
      setState(() => _error = AppLocalizations.of(context)!.securityPatternMinDots);
      HapticFeedback.heavyImpact();
      return;
    }

    setState(() => _error = '');

    if (widget.mode == 'setup') {
      if (!_isConfirming) {
        setState(() {
          _currentPattern = List.from(pattern);
          _isConfirming = true;
        });
      } else {
        if (_listEquals(pattern, _currentPattern)) {
          _savePattern(pattern);
        } else {
          setState(() {
            _error = AppLocalizations.of(context)!.securityPatternMismatch;
            _currentPattern = [];
            _isConfirming = false;
          });
          HapticFeedback.heavyImpact();
        }
      }
    } else {
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
    final types = prefs.getStringList('lock_types') ?? [];
    if (!types.contains('pattern')) {
      types.add('pattern');
      await prefs.setStringList('lock_types', types);
    }
    await prefs.setString('lock_type', 'pattern');

    if (mounted) {
      AppToast.show(context, AppLocalizations.of(context)!.securityPatternSetSuccess, duration: const Duration(milliseconds: 500));
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _verifyPattern(List<int> pattern) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPattern = prefs.getString('lock_pattern') ?? '';

    if (pattern.join(',') == savedPattern) {
      if (widget.onAuthenticated != null) {
        widget.onAuthenticated!();
      } else if (mounted) {
        Navigator.of(context).pop(true);
      }
    } else {
      setState(() {
        _error = AppLocalizations.of(context)!.securityPatternWrong;
        _currentPattern = [];
      });
      HapticFeedback.heavyImpact();
    }
  }
}

/// 图案绘制网格组件
class _PatternGridWidget extends StatefulWidget {
  final Function(List<int>) onPatternComplete;
  final AppColors colors;

  const _PatternGridWidget({
    required this.onPatternComplete,
    required this.colors,
  });

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

  Offset _getDotCenter(int index) {
    final row = index ~/ _cols;
    final col = index % _cols;
    return Offset(
      col * _cellSize + _cellSize / 2,
      row * _cellSize + _cellSize / 2,
    );
  }

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
          colors: widget.colors,
        ),
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  final List<int> selectedDots;
  final Offset? currentPosition;
  final Offset Function(int) getDotCenter;
  final bool isDrawing;
  final AppColors colors;

  _PatternPainter({
    required this.selectedDots,
    this.currentPosition,
    required this.getDotCenter,
    required this.isDrawing,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const int totalDots = 9;

    for (int i = 0; i < totalDots; i++) {
      final center = getDotCenter(i);
      final isSelected = selectedDots.contains(i);

      final outerPaint = Paint()
        ..color = isSelected
            ? colors.primary
            : colors.textTertiary.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(center, _PatternGridWidgetState._dotRadius, outerPaint);

      if (isSelected) {
        final innerPaint = Paint()
          ..color = colors.primary
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, 6, innerPaint);
      }
    }

    if (selectedDots.length >= 2) {
      final linePaint = Paint()
        ..color = colors.primary.withValues(alpha: 0.6)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < selectedDots.length - 1; i++) {
        final start = getDotCenter(selectedDots[i]);
        final end = getDotCenter(selectedDots[i + 1]);
        canvas.drawLine(start, end, linePaint);
      }

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
