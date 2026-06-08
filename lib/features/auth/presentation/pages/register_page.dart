import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// Mantengo tus imports originales
import '../providers/auth_provider.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';

// --- CONSTANTES DE ESTILO PARA LA PIZZERÍA ---
class PizzaColors {
  static const Color primaryRed = Color(0xFFD32F2F); // Rojo Pomodoro
  static const Color accentOrange = Color(0xFFFFA000); // Queso/Horno
  static const Color backgroundCrema = Color(0xFFFFF8E1); // Masa/Harina suave
  static const Color textDark = Color(0xFF3E2723); // Marrón corteza oscuro
  static const Color textSecondary = Color(0xFF795548);
}

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
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInCubic);
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
      // Fondo Crema idéntico al Login
      backgroundColor: PizzaColors.backgroundCrema,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBackButton(context),
                  const SizedBox(height: 20),

                  // Encabezado centrado y amigable
                  Center(child: _buildHeader()),
                  const SizedBox(height: 30),

                  // Tarjeta contenedor blanca para el formulario de registro
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: PizzaColors.textDark.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildFields(),
                        const SizedBox(height: 28),

                        if (auth.errorMessage != null) ...[
                          _buildError(auth.errorMessage!),
                          const SizedBox(height: 16),
                        ],

                        // Botón de acción principal
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: CustomButton(
                            label: 'Crear mi cuenta pizzera',
                            isLoading: isLoading,
                            onPressed: _submit,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildLoginLink(context),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  _buildSecurityNoteVisual(),
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
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: PizzaColors.textDark.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Padding(
          // Un pequeño ajuste de padding para centrar visualmente el icono 'ios'
          padding: EdgeInsets.only(left: 6),
          child: Icon(Icons.arrow_back_ios,
              color: PizzaColors.primaryRed, size: 18),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Text(
          '¡Únete a la Familia!',
          style: TextStyle(
            color: PizzaColors.primaryRed,
            fontSize: 34,
            fontWeight: FontWeight.w900,
            fontFamily: 'Serif', // Puedes usar tu fuente preferida
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Regístrate para empezar a ordenar tu pizza favorita',
          textAlign: TextAlign.center,
          style: TextStyle(color: PizzaColors.textSecondary, fontSize: 15),
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
          label: '¿Cómo te llamamos? (Nombre)',
          keyboardType: TextInputType.name,
          prefixIcon: const Icon(Icons.person_outline_rounded, color: PizzaColors.textSecondary),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Dinos tu nombre para la entrega';
            if (v.trim().length < 2) return 'El nombre debe ser más largo';
            return null;
          },
        ),
        const SizedBox(height: 18),

        // Email
        CustomTextField(
          controller: _emailCtrl,
          label: 'Correo electrónico',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.alternate_email_rounded, color: PizzaColors.textSecondary),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Ingresa tu correo pizzero';
            if (!v.contains('@') || !v.contains('.')) return 'Este correo no parece válido';
            return null;
          },
        ),
        const SizedBox(height: 18),

        // Contraseña
        CustomTextField(
          controller: _passwordCtrl,
          label: 'Contraseña',
          obscureText: _obscurePass,
          prefixIcon: const Icon(Icons.lock_open_rounded, color: PizzaColors.textSecondary),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: PizzaColors.textSecondary.withOpacity(0.5),
              size: 20,
            ),
            onPressed: () => setState(() => _obscurePass = !_obscurePass),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Elige una contraseña segura';
            if (v.length < 6) return 'Mínimo 6 ingredientes (caracteres)';
            return null;
          },
        ),
        const SizedBox(height: 18),

        // Confirmar contraseña
        CustomTextField(
          controller: _confirmCtrl,
          label: 'Confirmar contraseña',
          obscureText: _obscureConfirm,
          prefixIcon: const Icon(Icons.lock_outline_rounded, color: PizzaColors.textSecondary),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: PizzaColors.textSecondary.withOpacity(0.5),
              size: 20,
            ),
            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Asegura tu contraseña repitiéndola';
            if (v != _passwordCtrl.text) return 'Las contraseñas no combinan igual';
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
        color: PizzaColors.primaryRed.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PizzaColors.primaryRed.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.sentiment_very_dissatisfied, color: PizzaColors.primaryRed, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message,
                style: const TextStyle(
                    color: PizzaColors.primaryRed,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '¿Ya eres de la familia?',
          style: TextStyle(color: PizzaColors.textSecondary, fontSize: 14),
        ),
        TextButton(
          onPressed: () => context.pop(),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Inicia sesión',
            style: TextStyle(
              color: PizzaColors.primaryRed,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityNoteVisual() {
    return Opacity(
      opacity: 0.5,
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.lock_outline_rounded, size: 18, color: PizzaColors.textSecondary),
            const SizedBox(height: 6),
            Text(
              'Al registrarte, tu sesión se almacena de manera encriptada y segura\nbajo estándares de alta seguridad tecnológica (AES-256).',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: PizzaColors.textSecondary,
                  fontSize: 11,
                  fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}