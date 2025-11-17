import 'package:doist/generated/l10n.dart';
import 'package:doist/home_tab/data/models/task_model.dart';
import 'package:doist/home_tab/view/widgets/task.dart';
import 'package:doist/shared/app_theme.dart';
import 'package:doist/shared/font_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<TaskModel> tasks = [
    TaskModel(taskTitle: 'Hello'),
    TaskModel(taskTitle: 'welcome'),
    TaskModel(taskTitle: 'omar'),
    TaskModel(taskTitle: 'hi'),
    TaskModel(taskTitle: 'hi'),
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _controller,
                    keyboardType: TextInputType.multiline,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onTapOutside: (event) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    cursorColor: AppTheme.lightModeBlack,
                    decoration: InputDecoration(
                      hint: Text(
                        S.of(context).add_new_task,
                        style: TextStyle(
                          fontSize: FontManager.f16,
                          fontWeight: FontManager.regular,
                          color: AppTheme.lightModeTextGrey,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedContainer(
                  height: 56,
                  width: _controller.text.isEmpty
                      ? 0
                      : MediaQuery.sizeOf(context).width * 0.2,
                  curve: Curves.easeInOut,
                  duration: Duration(milliseconds: 200),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(8),
                        side: BorderSide(color: AppTheme.lightModeDividerGrey),
                      ),
                      backgroundColor: AppTheme.lightModeSecondry,
                    ),
                    onPressed: () {},
                    child: Icon(
                      CupertinoIcons.add,
                      size: 24,
                      color: AppTheme.lightModePrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.separated(
            itemBuilder: (context, index) => Task(
              model: tasks[index],
              onChanged: (val) {
                setState(() {
                  tasks[index] = tasks[index].copyWith(isChecked: val);
                });
              },
            ),
            separatorBuilder: (context, index) => const Divider(
              indent: 25,
              endIndent: 25,
              color: AppTheme.lightModeDividerGrey,
            ),
            itemCount: tasks.length,
          ),
        ),
      ],
    );
  }
}
