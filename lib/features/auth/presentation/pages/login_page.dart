import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authProvider.notifier).login(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final isLoading = auth.status == AuthStatus.loading;

    // Snackbar cuando la sesión se cierra por inactividad
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (prev?.status == AuthStatus.authenticated &&
          next.status == AuthStatus.unauthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.surfaceVariant,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            content: const Row(
              children: [
                Icon(Icons.lock_clock, color: AppColors.warning, size: 18),
                SizedBox(width: 10),
                Text(
                  'Sesión cerrada por inactividad',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 64),
                  _buildHeader(),
                  const SizedBox(height: 48),
                  _buildFields(),
                  const SizedBox(height: 12),
                  _buildInactivityNote(),
                  const SizedBox(height: 28),
                  if (auth.errorMessage != null) ...[
                    _buildError(auth.errorMessage!),
                    const SizedBox(height: 16),
                  ],
                  CustomButton(
                    label: 'Iniciar sesión',
                    isLoading: isLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 20),
                  _buildRegisterLink(context),
                  const SizedBox(height: 32),
                  _buildSecurityNote(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AppColors.accent.withOpacity(0.3), width: 1.5),
          ),
          child: const Icon(Icons.account_balance_wallet_outlined,
              color: AppColors.accent, size: 26),
        ),
        const SizedBox(height: 24),
        const Text(
          'GastosIO',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Inicia sesión para continuar',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildFields() {
    return Column(
      children: [
        CustomTextField(
          controller: _emailCtrl,
          label: 'Correo electrónico',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.mail_outline_rounded),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Ingresa tu correo';
            if (!v.contains('@')) return 'Correo inválido';
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _passwordCtrl,
          label: 'Contraseña',
          obscureText: _obscure,
          prefixIcon: const Icon(Icons.lock_outline_rounded),
          suffixIcon: IconButton(
            icon: Icon(
              _obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.textSecondary,
              size: 20,
            ),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
            if (v.length < 6) return 'Mínimo 6 caracteres';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildInactivityNote() {
    return Row(
      children: [
        const Icon(Icons.timer_outlined,
            size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          'Cierre automático tras ${kInactivitySeconds}s de inactividad',
          style:
          const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildError(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style:
                const TextStyle(color: AppColors.error, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterLink(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '¿No tienes cuenta?',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          TextButton(
            onPressed: () => context.push('/register'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Regístrate',
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, size: 15, color: AppColors.accent),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tu token y tiempo de sesión se guardan en almacén encriptado (AES-256 / Keystore).',
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 11.5),
            ),
          ),
        ],
      ),
    );
  }
}