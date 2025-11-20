import 'package:doist/generated/l10n.dart';
import 'package:doist/home_tab/view_model/home_tab_events.dart';
import 'package:doist/home_tab/view_model/home_tab_view_model.dart';
import 'package:doist/settings_tab/view_model/settings_view_model.dart';
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
    final bool hasText = _controller.text.isNotEmpty;

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
              style: TextStyle(
                locale: Locale(
                  context.read<SettingsBloc>().state.model.language,
                ),
                color:
                    context.read<SettingsBloc>().state.model.themeMode ==
                        ThemeMode.light
                    ? AppTheme.lightModeBlack
                    : AppTheme.darkModeWhite,
              ),
              decoration: InputDecoration(
                hintText: S.of(context).add_new_task,
                hintStyle: TextStyle(
                  fontSize: FontManager.f16,
                  fontWeight: FontManager.regular,
                  color: AppTheme.lightModeTextGrey,
                ),
                suffix: AnimatedOpacity(
                  opacity: hasText ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 200),
                  child: AnimatedScale(
                    scale: hasText ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: GestureDetector(
                      onTap: hasText
                          ? () {
                              context.read<HomeTabBloc>().add(
                                HomeTabAddTask(taskTitle: _controller.text),
                              );
                              _controller.clear();
                            }
                          : null,
                      child: Container(
                        height: MediaQuery.sizeOf(context).width * 0.08,
                        width: MediaQuery.sizeOf(context).width * 0.10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                context
                                        .read<SettingsBloc>()
                                        .state
                                        .model
                                        .themeMode ==
                                    ThemeMode.light
                                ? AppTheme.lightModeDividerGrey
                                : AppTheme.darkModeLightGrey,
                          ),
                          color: AppTheme.lightModeSecondry,
                        ),
                        child: Icon(
                          CupertinoIcons.add,
                          size: 18,
                          color: AppTheme.lightModePrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
