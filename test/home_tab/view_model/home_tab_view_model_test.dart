import 'package:bloc_test/bloc_test.dart';
import 'package:doist/home_tab/data/models/task_model.dart';
import 'package:doist/home_tab/view_model/home_tab_events.dart';
import 'package:doist/home_tab/view_model/home_tab_states.dart';
import 'package:doist/home_tab/view_model/home_tab_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockStorage extends Mock implements Storage {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomeTabBloc--', () {
    late HomeTabBloc homeTabBloc;
    late Storage storage;

    setUp(() {
      storage = MockStorage();
      when(() => storage.write(any(), any<dynamic>())).thenAnswer((_) async {});
      HydratedBloc.storage = storage;
      homeTabBloc = HomeTabBloc();
    });

    test('initial state is HomeTabInitial with an empty list', () {
      expect(homeTabBloc.state, const HomeTabInitial(tasksList: []));
    });

    blocTest<HomeTabBloc, HomeTabState>(
      'emits [HomeTabUpdate] state when HomeTabAddTask event is added.',
      build: () => homeTabBloc,
      act: (bloc) => bloc.add(HomeTabAddTask(taskTitle: 'Test Task')),
      expect: () => [
        isA<HomeTabUpdate>().having(
          (state) => state.tasksList.length,
          'tasksList.length',
          1,
        ),
      ],
    );

    blocTest<HomeTabBloc, HomeTabState>(
      'emits [HomeTabUpdate] state when HomeTabDeleteTask event is added.',
      build: () => homeTabBloc,
      seed: () => HomeTabUpdate(tasksList: [TaskModel(taskTitle: 'Test Task')]),
      act: (bloc) {
        final taskId = bloc.state.tasksList.first.id;
        bloc.add(HomeTabDeleteTask(taskId: taskId));
      },
      expect: () => [const HomeTabUpdate(tasksList: [])],
    );

    blocTest<HomeTabBloc, HomeTabState>(
      'emits [HomeTabUpdate] state when HomeTabUpdateCheckedForTask event is added.',
      build: () => homeTabBloc,
      seed: () => HomeTabUpdate(tasksList: [TaskModel(taskTitle: 'Test Task')]),
      act: (bloc) {
        final task = bloc.state.tasksList.first;
        bloc.add(HomeTabUpdateCheckedForTask(taskId: task.id));
      },
      expect: () => [
        isA<HomeTabUpdate>().having(
          (state) => state.tasksList.first.isChecked,
          'task.isChecked',
          true,
        ),
      ],
    );
  });
}
