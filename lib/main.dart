import 'package:flutter/material.dart';

import 'pages/main_shell.dart';

void main() => runApp(const YurishApp());

class YurishApp extends StatelessWidget {
  const YurishApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Yurish hisoblagich',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
    home: const MainShell(),
  );
}