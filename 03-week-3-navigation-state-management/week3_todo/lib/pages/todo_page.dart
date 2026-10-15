import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/todo_provider.dart';
import '../widgets/todo_tile.dart';

class TodoPage extends ConsumerWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(filteredTodosProvider);
    final filter = ref.watch(todoFilterProvider);
    final total = ref.watch(todoListProvider).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDo Riverpod'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            child: SegmentedButton<TodoFilter>(
              segments: const [
                ButtonSegment(
                  value: TodoFilter.all,
                  label: Text('Semua'),
                ),
                ButtonSegment(
                  value: TodoFilter.active,
                  label: Text('Aktif'),
                ),
                ButtonSegment(
                  value: TodoFilter.done,
                  label: Text('Selesai'),
                ),
              ],
              selected: {filter},
              onSelectionChanged: (selection) {
                ref
                    .read(todoFilterProvider.notifier)
                    .set(selection.first);
              },
            ),
          ),
          Expanded(
            child: total == 0
                ? const Center(child: Text('Belum ada tugas'))
                : todos.isEmpty
                    ? const Center(child: Text('Tidak ada tugas di filter ini'))
                    : ListView.builder(
                        itemCount: todos.length,
                        itemBuilder: (context, index) {
                          return TodoTile(todo: todos[index]);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDialog(context, ref);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(
    BuildContext context,
    WidgetRef ref,
  ) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tugas baru'),
          content: TextField(
            controller: controller,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  ref
                      .read(todoListProvider.notifier)
                      .add(controller.text.trim());
                }

                Navigator.pop(context);
              },
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }
}
