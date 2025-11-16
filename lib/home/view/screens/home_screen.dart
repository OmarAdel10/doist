import 'package:doist/generated/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = '/home';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localization.appTitle),
        actions: [
          IconButton(onPressed: (){}, icon: Icon(CupertinoIcons.add))
        ],
      ),
    );
  }
}
