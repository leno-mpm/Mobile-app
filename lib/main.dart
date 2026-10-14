
import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'view/dashboard_view.dart';

void main() {
  runApp(const MintApp());
}

class MintApp extends StatelessWidget {
  const MintApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mint',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const DashboardView(),
    );
  }
}
