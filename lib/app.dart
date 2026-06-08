import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/routes/auth_routes.dart';
import 'shared/theme/app_theme.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(authRouterProvider);

    return GestureDetector(
      // Cualquier toque en la app notifica interacción al notifier.
      // El notifier decide si arrancar o reiniciar el timer según el estado.
      onTap: () => ref.read(authProvider.notifier).onUserInteraction(),
      onPanDown: (_) => ref.read(authProvider.notifier).onUserInteraction(),
      behavior: HitTestBehavior.translucent,
      child: MaterialApp.router(
        title: 'GastosIO',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        routerConfig: router,
      ),
    );
  }
}