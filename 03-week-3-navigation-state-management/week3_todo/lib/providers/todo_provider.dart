import 'package:flutter_riverpod/flutter_riverpod.dart';

class Todo {
  Todo(
    this.title, {
    this.done = false,
  });

  final String title;
  final bool done;

  Todo copyWith({
    String? title,
    bool? done,
  }) {
    return Todo(
      title ?? this.title,
      done: done ?? this.done,
    );
  }
}

class TodoListNotifier extends Notifier<List<Todo>> {
  @override
  List<Todo> build() {
    return [];
  }

  void add(String title) {
    state = [
      ...state,
      Todo(title),
    ];
  }

  // Operate on the Todo itself, not its index, so toggling stays correct
  // while the list is filtered.
  void toggle(Todo target) {
    state = [
      for (final todo in state)
        if (identical(todo, target))
          todo.copyWith(done: !todo.done)
        else
          todo,
    ];
  }

  void remove(Todo target) {
    state = state.where((todo) => !identical(todo, target)).toList();
  }
}

final todoListProvider =
    NotifierProvider<TodoListNotifier, List<Todo>>(
  TodoListNotifier.new,
);

enum TodoFilter {
  all,
  active,
  done,
}

class TodoFilterNotifier extends Notifier<TodoFilter> {
  @override
  TodoFilter build() {
    return TodoFilter.all;
  }

  void set(TodoFilter filter) {
    state = filter;
  }
}

final todoFilterProvider =
    NotifierProvider<TodoFilterNotifier, TodoFilter>(
  TodoFilterNotifier.new,
);

// Derived provider: recomputes whenever the todo list or the filter changes.
final filteredTodosProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoListProvider);
  final filter = ref.watch(todoFilterProvider);

  switch (filter) {
    case TodoFilter.active:
      return todos.where((todo) => !todo.done).toList();
    case TodoFilter.done:
      return todos.where((todo) => todo.done).toList();
    case TodoFilter.all:
      return todos;
  }
});
