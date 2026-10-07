import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';
import '../widgets/note_tile.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkMode = ref.watch(darkModeProvider);
    final lastOpened = ref.watch(lastOpenedProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Tema gelap'),
            subtitle: const Text('Disimpan dengan SharedPreferences'),
            value: darkMode.value ?? false,
            onChanged: darkMode.isLoading
                ? null
                : (_) => ref.read(darkModeProvider.notifier).toggle(),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Terakhir dibuka'),
            subtitle: Text(
              lastOpened.when(
                data: (value) {
                  final parsed = DateTime.tryParse(value ?? '');
                  return parsed == null ? '-' : formatUpdatedAt(parsed);
                },
                loading: () => 'Memuat...',
                error: (error, _) => 'Gagal membaca preferensi',
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Preferensi kecil (tema, waktu terakhir dibuka) disimpan sebagai '
              'key-value. Daftar catatan tidak pernah disimpan di sini karena '
              'koleksi butuh query dan update parsial.',
            ),
          ),
        ],
      ),
    );
  }
}
