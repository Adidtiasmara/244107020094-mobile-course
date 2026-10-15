import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../messaging/push_service.dart';
import '../messaging/route_parser.dart';
import '../providers/auth_provider.dart';
import '../routes.dart';

/// Halaman bukti: token terpotong, rotasi token, langganan topik, dan simulasi
/// pesan masuk untuk menguji deep link.
class DebugPage extends ConsumerStatefulWidget {
  const DebugPage({super.key});

  @override
  ConsumerState<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends ConsumerState<DebugPage> {
  final _route = TextEditingController(text: AppRoutes.announcement('3'));

  static const Map<String, dynamic> _samplePayload = {
    'route': '/pengumuman/3',
    'id': '3',
  };

  @override
  void dispose() {
    _route.dispose();
    super.dispose();
  }

  Future<void> _rotateToken() async {
    final token = await simulateTokenRefresh();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Token diperbarui: ${token == null ? 'tidak tersedia' : maskToken(token)}',
        ),
      ),
    );
  }

  Future<void> _sendTestNotification() async {
    final route = routeFromMessage({'route': _route.text});
    await simulateIncoming(route: route);
  }

  Future<void> _simulateOpened(String state) async {
    final route = routeFromMessage({'route': _route.text});
    await simulateOpened(state: state, route: route);
  }

  @override
  Widget build(BuildContext context) {
    final token = ref.watch(fcmTokenProvider);
    final permission = ref.watch(notificationPermissionProvider);
    final subscribed = ref.watch(subscribedTopicProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final String permissionLabel;
    if (permission == null) {
      permissionLabel = 'Belum diminta';
    } else if (permission) {
      permissionLabel = 'Diizinkan';
    } else {
      permissionLabel = 'Ditolak';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Debug FCM')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _SectionCard(
            title: 'Lingkungan',
            children: [
              _InfoRow(
                label: 'Platform',
                value: defaultTargetPlatform.name,
              ),
              _InfoRow(label: 'Izin notifikasi', value: permissionLabel),
              _InfoRow(
                label: 'Topik pengumuman-kampus',
                value: subscribed ? 'Berlangganan' : 'Belum berlangganan',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Token perangkat',
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SelectableText(
                  token == null ? 'Belum tersedia' : maskToken(token),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 16,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Token penuh tidak pernah ditampilkan atau ditulis ke log. '
                      'Yang tampil hanya 12 karakter pertama.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _rotateToken,
                icon: const Icon(Icons.autorenew),
                label: const Text('Simulasikan rotasi token'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Uji deep link',
            children: [
              TextField(
                controller: _route,
                decoration: const InputDecoration(
                  labelText: 'Route dari payload data',
                  prefixIcon: Icon(Icons.route_outlined),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _sendTestNotification,
                icon: const Icon(Icons.send_outlined),
                label: const Text('Kirim notifikasi uji'),
              ),
              const SizedBox(height: 8),
              Text(
                'Foreground: banner lokal muncul dan ketukan mengarah ke rute. '
                'Background dan terminated memakai handler yang sama dengan '
                'payload ini.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _simulateOpened('background'),
                      child: const Text('Klik background'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _simulateOpened('terminated'),
                      child: const Text('Klik terminated'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Parsing payload',
            children: [
              Text(
                'data = $_samplePayload',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              ),
              const SizedBox(height: 10),
              _InfoRow(
                label: 'routeFromMessage',
                value: routeFromMessage(_samplePayload),
                monospace: true,
              ),
              _InfoRow(
                label: 'announcementIdFromMessage',
                value: announcementIdFromMessage(_samplePayload) ?? '-',
                monospace: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.monospace = false,
  });

  final String label;
  final String value;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontFamily: monospace ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
