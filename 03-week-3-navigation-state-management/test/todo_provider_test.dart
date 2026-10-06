import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:week3_todo/providers/todo_provider.dart';

void main() {
  test('add, toggle, dan remove menghasilkan state baru', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(todoListProvider.notifier);

    notifier.add('PR minggu 3');
    expect(container.read(todoListProvider).length, 1);

    notifier.toggle(container.read(todoListProvider).first);
    expect(container.read(todoListProvider).first.done, true);

    notifier.remove(container.read(todoListProvider).first);
    expect(container.read(todoListProvider), isEmpty);
  });

  test('filteredTodosProvider mengikuti filter', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(todoListProvider.notifier);
    notifier.add('Tugas A');
    notifier.add('Tugas B');
    notifier.toggle(container.read(todoListProvider).first);

    container.read(todoFilterProvider.notifier).set(TodoFilter.active);
    expect(container.read(filteredTodosProvider).single.title, 'Tugas B');

    container.read(todoFilterProvider.notifier).set(TodoFilter.done);
    expect(container.read(filteredTodosProvider).single.title, 'Tugas A');
  });
}
