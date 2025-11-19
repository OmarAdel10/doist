import 'package:doist/generated/l10n.dart';
import 'package:doist/home_tab/view_model/home_tab_events.dart';
import 'package:doist/home_tab/view_model/home_tab_view_model.dart';
import 'package:doist/shared/app_theme.dart';
import 'package:doist/shared/font_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({super.key});

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final _controller = TextEditingController();

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
    return Padding(
      padding: const EdgeInsets.all(16),
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
              onPressed: () async {
                context.read<HomeTabBloc>().add(
                  HomeTabAddTask(taskTitle: _controller.text),
                );
                _controller.clear();
              },
              child: Icon(
                CupertinoIcons.add,
                size: 24,
                color: AppTheme.lightModePrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
