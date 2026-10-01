import 'package:doist/home_tab/view/widgets/task_tile.dart';
import 'package:doist/home_tab/view_model/home_tab_events.dart';
import 'package:doist/home_tab/view_model/home_tab_states.dart';
import 'package:doist/home_tab/view_model/home_tab_view_model.dart';
import 'package:doist/shared/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lottie/lottie.dart';

class TasksList extends StatelessWidget {
  const TasksList({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocBuilder<HomeTabBloc, HomeTabState>(
        builder: (context, state) {
          return state.tasksList.isEmpty
              ? Lottie.asset(
                  'assets/lottie/empty.json',
                  width: MediaQuery.sizeOf(context).width * 0.5,
                  height: MediaQuery.sizeOf(context).width * 0.5,
                  fit: BoxFit.contain,
                )
              : ListView.separated(
                  itemBuilder: (context, index) => Slidable(
                    endActionPane: ActionPane(
                      motion: StretchMotion(),
                      extentRatio: 0.3,
                      children: [
                        SlidableAction(
                          onPressed: (context) =>
                              context.read<HomeTabBloc>().add(
                                HomeTabDeleteTask(
                                  taskId: state.tasksList[index].id,
                                ),
                              ),
                          backgroundColor: Colors.redAccent,
                          icon: CupertinoIcons.delete,
                          foregroundColor: AppTheme.lightModePrimary,
                        ),
                      ],
                    ),
                    child: TaskTile(
                      model: state.tasksList[index],
                      onChanged: (val) => context.read<HomeTabBloc>().add(
                        HomeTabUpdateCheckedForTask(
                          taskId: state.tasksList[index].id,
                        ),
                      ),
                    ),
                  ),
                  separatorBuilder: (context, index) => const Divider(
                    indent: 25,
                    endIndent: 25,
                    color: AppTheme.lightModeDividerGrey,
                  ),
                  itemCount: state.tasksList.length,
                );
        },
      ),
    );
  }
}
