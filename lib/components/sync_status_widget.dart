import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/background_steps_tracker.dart';
import '../services/offline_sync_service.dart';

/// Widget untuk menampilkan status sinkronisasi langkah
class SyncStatusWidget extends StatefulWidget {
  const SyncStatusWidget({super.key});

  @override
  State<SyncStatusWidget> createState() => _SyncStatusWidgetState();
}

class _SyncStatusWidgetState extends State<SyncStatusWidget> {
  bool _isSyncing = false;
  int _todaySteps = 0;
  bool _isTracking = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    if (mounted) {
      setState(() {
        _todaySteps = BackgroundStepsTracker.todaySteps;
        _isTracking = BackgroundStepsTracker.isListening;
      });
    }
  }

  Future<void> _syncNow() async {
    if (_isSyncing) return;

    setState(() => _isSyncing = true);

    try {
      // Sync SQLite  Server
      await OfflineSyncService.autoSyncOnAppStart();
      // Sync langkah ke server
      final result = await BackgroundStepsTracker.syncNow();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Sinkronisasi selesai'),
            backgroundColor: result['success'] == true
                ? const Color(0xFF00C97A)
                : Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        await _loadStatus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C97A).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const FaIcon(
                    FontAwesomeIcons.arrowsRotate,
                    color: Color(0xFF00C97A),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status Sinkronisasi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      Text(
                        _isTracking
                            ? 'Tracking aktif - $_todaySteps langkah hari ini'
                            : 'Tracking tidak aktif',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF718096),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isSyncing)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF00C97A),
                      ),
                    ),
                  )
                else
                  IconButton(
                    onPressed: _syncNow,
                    icon: const FaIcon(
                      FontAwesomeIcons.arrowsRotate,
                      size: 16,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF00C97A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(8),
                    ),
                    tooltip: 'Sinkronkan Sekarang',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
