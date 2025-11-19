import 'package:doist/home_tab/view/widgets/custom_text_field.dart';
import 'package:doist/home_tab/view/widgets/tasks_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(),
        const SizedBox(height: 10),
        TasksList(),
      ],
    );
  }
}
