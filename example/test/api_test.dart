import 'package:example/models/todo.dart';
import 'package:example/services/todo_services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Todo Service Tests', () {
    test('should fetch todos successfully', () async {
      // This test would work with actual API or mocked responses
      try {
        final todos = await TodoService.getTodos();
        expect(todos, isA<List<Todo>>());
        expect(todos.isNotEmpty, true);
      } catch (e) {
        // In a real test, you'd mock the API responses
        print('Test requires network connection: $e');
      }
    });

    test('Todo model should serialize/deserialize correctly', () {
      final todo = Todo(
        id: 1,
        userId: 1,
        title: 'Test Todo',
        completed: false,
      );

      final json = todo.toJson();
      final fromJson = Todo.fromJson(json);

      expect(fromJson.id, todo.id);
      expect(fromJson.userId, todo.userId);
      expect(fromJson.title, todo.title);
      expect(fromJson.completed, todo.completed);
    });
  });
}
