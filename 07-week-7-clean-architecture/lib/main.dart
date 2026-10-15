import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/settings/presentation/providers/settings_providers.dart';
import 'routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Composition root: repository diakses lewat provider (DI), bukan `new`
  // langsung di widget. Container dibuat sekali dan diserahkan ke aplikasi.
  final container = ProviderContainer();
  await container.read(settingsRepositoryProvider).markOpenedNow();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const CleanNotesApp(),
    ),
  );
}

class CleanNotesApp extends ConsumerWidget {
  const CleanNotesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(darkModeProvider).value ?? false;
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Week 7 - Clean Architecture',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
    );
  }
}
