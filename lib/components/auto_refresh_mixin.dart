import 'dart:async';
import 'package:flutter/widgets.dart';

/// Mixin untuk auto-refresh data secara periodik pada halaman.
///
/// Panggil [startAutoRefresh] dari `initState` dengan fungsi refresh data.
/// Timer otomatis dibatalkan saat widget di-dispose.
mixin AutoRefreshMixin<T extends StatefulWidget> on State<T> {
  Timer? _autoRefreshTimer;

  /// Mulai auto-refresh berkala setiap [interval].
  void startAutoRefresh({
    required Future<void> Function() refresh,
    Duration interval = const Duration(seconds: 30),
  }) {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(interval, (_) {
      if (mounted) {
        refresh();
      }
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
    super.dispose();
  }
}
