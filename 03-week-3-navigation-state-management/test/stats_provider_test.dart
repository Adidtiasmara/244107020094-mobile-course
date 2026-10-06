import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:week3_todo/providers/stats_provider.dart';
import 'package:week3_todo/providers/todo_provider.dart';

void main() {
  test('statistik sukses menghitung total, selesai, dan sisa', () async {
    final container = ProviderContainer(
      retry: (retryCount, error) => null,
      overrides: [
        statsProvider.overrideWith(
          () => StatsNotifier(
            random: Random(0),
            delay: Duration.zero,
            failureRate: 0,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final todos = container.read(todoListProvider.notifier);
    todos.add('Tugas A');
    todos.add('Tugas B');
    todos.toggle(container.read(todoListProvider).first);

    final stats = await container.read(statsProvider.future);

    expect(stats.total, 2);
    expect(stats.done, 1);
    expect(stats.remaining, 1);
    expect(stats.percent, 50);
  });

  test('statistik gagal memunculkan AsyncError', () async {
    final container = ProviderContainer(
      retry: (retryCount, error) => null,
      overrides: [
        statsProvider.overrideWith(
          () => StatsNotifier(
            random: Random(0),
            delay: Duration.zero,
            failureRate: 1,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(statsProvider.future),
      throwsA(isA<Exception>()),
    );
  });
}
