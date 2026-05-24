import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'shared/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seguridad de la Información',
      debugShowCheckedModeBanner: false,
      // DevicePreview hooks
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: AppTheme.light,
      home: const LoginPage(),
    );
  }
}