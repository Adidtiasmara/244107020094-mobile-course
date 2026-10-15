import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'todo_provider.dart';

/// Ringkasan statistik tugas. Angka dihitung dari daftar tugas sungguhan,
/// bukan nilai tetap, supaya halaman tidak pernah menampilkan data palsu.
class Stats {
  const Stats({required this.total, required this.done});

  final int total;
  final int done;

  int get remaining => total - done;

  double get completion => total == 0 ? 0 : done / total;

  int get percent => (completion * 100).round();
}

/// Mensimulasikan pengambilan data statistik: menunggu lalu kadang gagal.
/// Random dan durasi dapat di-inject agar unit test deterministik.
class StatsNotifier extends AsyncNotifier<Stats> {
  StatsNotifier({
    Random? random,
    this.delay = const Duration(seconds: 2),
    this.failureRate = 0.3,
  }) : _random = random ?? Random();

  final Random _random;
  final Duration delay;
  final double failureRate;

  @override
  Future<Stats> build() => _fetch();

  Future<Stats> _fetch() async {
    await Future<void>.delayed(delay);

    if (_random.nextDouble() < failureRate) {
      throw Exception('Gagal terhubung ke server');
    }

    final todos = ref.read(todoListProvider);
    return Stats(
      total: todos.length,
      done: todos.where((todo) => todo.done).length,
    );
  }

  /// Memuat ulang sambil menampilkan loading. `AsyncValue.guard` mengubah
  /// exception menjadi AsyncError, jadi UI tetap menangani ketiga kondisi.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

final statsProvider =
    AsyncNotifierProvider<StatsNotifier, Stats>(StatsNotifier.new);
