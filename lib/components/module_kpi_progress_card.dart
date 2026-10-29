import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/api_service.dart';
import 'data_refresh_notifier.dart';

/// Kartu ringkas progress KPI per modul (SEHAT/TENANG/HIJAU).
/// Menampilkan poin tercapai / poin maksimal dengan progress bar.
class ModuleKpiProgressCard extends StatefulWidget {
  final String module; // 'sehat' | 'tenang' | 'hijau'
  final Color primaryColor;
  final Color gradientEnd;
  final VoidCallback? onTap;

  const ModuleKpiProgressCard({
    super.key,
    required this.module,
    required this.primaryColor,
    required this.gradientEnd,
    this.onTap,
  });

  @override
  State<ModuleKpiProgressCard> createState() => _ModuleKpiProgressCardState();
}

class _ModuleKpiProgressCardState extends State<ModuleKpiProgressCard> {
  bool _loading = true;
  int _poinBulan = 0;
  int _poinMaks = 0;
  String _namaBulan = '';
  String _predikat = '';

  @override
  void initState() {
    super.initState();
    DataRefreshNotifier.instance.addListener(_onDataChanged);
    _load();
  }

  void _onDataChanged() {
    if (mounted) _load();
  }

  @override
  void dispose() {
    DataRefreshNotifier.instance.removeListener(_onDataChanged);
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final response = await ApiService.get('/user/kpi-${widget.module}/bulanan');
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'] ?? {};
        final ringkasan = data['ringkasan'] ?? {};
        final periode = data['periode'] ?? {};
        if (!mounted) return;
        setState(() {
          _poinBulan = (ringkasan['total_poin'] ?? 0).toInt();
          _poinMaks = (ringkasan['maks_poin_bulan'] ?? 0).toInt();
          _namaBulan = periode['nama_bulan'] ?? '';
          _predikat = ringkasan['predikat'] ?? '';
          _loading = false;
        });
        return;
      }
    } catch (_) {}
    if (!mounted) return;
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final double pct = _poinMaks > 0 ? (_poinBulan / _poinMaks * 100).clamp(0.0, 100.0) : 0.0;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [widget.primaryColor, widget.gradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: widget.primaryColor.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _loading
            ? const Row(
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                  SizedBox(width: 12),
                  Text('Memuat KPI...', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              )
            : _buildContent(pct),
      ),
    );
  }

  Widget _buildContent(double pct) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _moduleIcon,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'KPI $moduleName',
                    style: const TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500),
                  ),
                  if (_namaBulan.isNotEmpty)
                    Text(
                      _namaBulan,
                      style: const TextStyle(fontSize: 11, color: Colors.white54),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$_poinBulan',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    ' / $_poinMaks poin',
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                  if (_predikat.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _predikat,
                        style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: pct / 100,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${pct.toStringAsFixed(0)}% tercapai',
                style: const TextStyle(fontSize: 11, color: Colors.white60),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const FaIcon(FontAwesomeIcons.chevronRight, size: 12, color: Colors.white60),
      ],
    );
  }

  FaIcon get _moduleIcon {
    switch (widget.module) {
      case 'sehat':
        return const FaIcon(FontAwesomeIcons.heartPulse, color: Colors.white, size: 22);
      case 'tenang':
        return const FaIcon(FontAwesomeIcons.brain, color: Colors.white, size: 22);
      case 'hijau':
        return const FaIcon(FontAwesomeIcons.leaf, color: Colors.white, size: 22);
      default:
        return const FaIcon(FontAwesomeIcons.chartBar, color: Colors.white, size: 22);
    }
  }

  String get moduleName {
    switch (widget.module) {
      case 'sehat':
        return 'Sehat 360';
      case 'tenang':
        return 'Tenang 360';
      case 'hijau':
        return 'Hijau 360';
      default:
        return '';
    }
  }
}
