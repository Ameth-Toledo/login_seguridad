import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;

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
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authProvider.notifier).register(
      nombre: _nombreCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final isLoading = auth.status == AuthStatus.loading;

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
                  const SizedBox(height: 24),
                  _buildBackButton(context),
                  const SizedBox(height: 28),
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildFields(),
                  const SizedBox(height: 28),
                  if (auth.errorMessage != null) ...[
                    _buildError(auth.errorMessage!),
                    const SizedBox(height: 16),
                  ],
                  CustomButton(
                    label: 'Crear cuenta',
                    isLoading: isLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 20),
                  _buildLoginLink(context),
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

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pop(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded,
            color: AppColors.textSecondary, size: 16),
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
          child: const Icon(Icons.person_add_outlined,
              color: AppColors.accent, size: 26),
        ),
        const SizedBox(height: 24),
        const Text(
          'Crear cuenta',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Regístrate para empezar a controlar tus finanzas',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildFields() {
    return Column(
      children: [
        // Nombre
        CustomTextField(
          controller: _nombreCtrl,
          label: 'Nombre completo',
          keyboardType: TextInputType.name,
          prefixIcon: const Icon(Icons.person_outline_rounded),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Ingresa tu nombre';
            if (v.trim().length < 2) return 'Nombre muy corto';
            return null;
          },
        ),
        const SizedBox(height: 16),
        // Email
        CustomTextField(
          controller: _emailCtrl,
          label: 'Correo electrónico',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.mail_outline_rounded),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Ingresa tu correo';
            if (!v.contains('@') || !v.contains('.'))
              return 'Correo inválido';
            return null;
          },
        ),
        const SizedBox(height: 16),
        // Contraseña
        CustomTextField(
          controller: _passwordCtrl,
          label: 'Contraseña',
          obscureText: _obscurePass,
          prefixIcon: const Icon(Icons.lock_outline_rounded),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePass
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.textSecondary,
              size: 20,
            ),
            onPressed: () => setState(() => _obscurePass = !_obscurePass),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Ingresa una contraseña';
            if (v.length < 6) return 'Mínimo 6 caracteres';
            return null;
          },
        ),
        const SizedBox(height: 16),
        // Confirmar contraseña
        CustomTextField(
          controller: _confirmCtrl,
          label: 'Confirmar contraseña',
          obscureText: _obscureConfirm,
          prefixIcon: const Icon(Icons.lock_outline_rounded),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirm
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.textSecondary,
              size: 20,
            ),
            onPressed: () =>
                setState(() => _obscureConfirm = !_obscureConfirm),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Confirma tu contraseña';
            if (v != _passwordCtrl.text) return 'Las contraseñas no coinciden';
            return null;
          },
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

  Widget _buildLoginLink(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '¿Ya tienes cuenta?',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          TextButton(
            onPressed: () => context.pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Inicia sesión',
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
              'Al registrarte, tu token se guardará en almacén encriptado (AES-256 / Keystore) de forma segura.',
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 11.5),
            ),
          ),
        ],
      ),
    );
  }
}