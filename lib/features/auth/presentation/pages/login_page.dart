import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// Mantengo tus imports originales
import '../providers/auth_provider.dart';
// Nota: Asumiremos que AppColors tiene los colores antiguos,
// pero definiremos unos locales aquí para la pizzería.
// Si quieres usarlos globalmente, cámbialos en app_colors.dart
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';

// --- CONSTANTES DE ESTILO PARA LA PIZZERÍA ---
// Puedes mover esto a app_colors.dart después
class PizzaColors {
  static const Color primaryRed = Color(0xFFD32F2F); // Rojo Pomodoro
  static const Color accentOrange = Color(0xFFFFA000); // Queso/Horno
  static const Color backgroundCrema = Color(0xFFFFF8E1); // Masa/Harina suave
  static const Color textDark = Color(0xFF3E2723); // Marrón corteza oscuro
  static const Color textSecondary = Color(0xFF795548);
}

// Supongamos que esta constante existe en tu código original, la defino aquí para que no de error
const int kInactivitySeconds = 120;

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
      duration: const Duration(milliseconds: 800), // Un poco más lento para suavidad
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInCubic);
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

    // Escuchador de Riverpod intacto
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (prev?.status == AuthStatus.authenticated &&
          next.status == AuthStatus.unauthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: PizzaColors.textDark, // Color más acorde
            behavior: SnackBarBehavior.floating,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: const Row(
              children: [
                Icon(Icons.timer_off_outlined,
                    color: PizzaColors.accentOrange, size: 20),
                SizedBox(width: 10),
                Text(
                  'Tu sesión horneada ha expirado',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        );
      }
    });

    return Scaffold(
      // 1. Fondo Crema suave
      backgroundColor: PizzaColors.backgroundCrema,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          // Stack para poner un detalle decorativo de fondo si quisieras
          child: SingleChildScrollView(
            // Un padding más estético
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // Centrado
                children: [
                  // 2. Cabecera Pizzería
                  _buildPizzaHeader(),
                  const SizedBox(height: 30),

                  // 3. Contenedor Blanco (Card) para el formulario
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28), // Muy redondeado
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
                        const Text(
                          "Ingresa tus datos",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: PizzaColors.textDark),
                        ),
                        const SizedBox(height: 25),
                        // 4. Campos (reutilizando tus widgets)
                        _buildFields(),
                        const SizedBox(height: 16),
                        _buildInactivityNote(),
                        const SizedBox(height: 30),

                        if (auth.errorMessage != null) ...[
                          _buildError(auth.errorMessage!),
                          const SizedBox(height: 16),
                        ],

                        // 5. Botón Principal (Rojo Pomodoro)
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: CustomButton(
                            label: '¡A pedir pizza!',
                            isLoading: isLoading,
                            onPressed: _submit,
                            // Aquí asumo que tu CustomButton permite cambiar el color.
                            // Si no, tendrás que editar CustomButton o envolverlo.
                            // color: PizzaColors.primaryRed,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildRegisterLink(context),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                  // La nota de seguridad la hacemos MUY sutil al final
                  _buildSecurityNoteVisual(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGETS DE LA INTERFAZ REDISEÑADOS ---

  Widget _buildPizzaHeader() {
    return Column(
      children: [
        // Icono grande y bonito
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: PizzaColors.primaryRed.withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 5))
            ],
          ),
          child: const Icon(
            Icons.local_pizza_rounded, // Icono de Pizza!
            color: PizzaColors.primaryRed,
            size: 60,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Bella Napoli', // Nombre de ejemplo de la pizzería
          style: TextStyle(
            color: PizzaColors.primaryRed,
            fontSize: 36,
            fontWeight: FontWeight.w900, // Muy negrita
            fontFamily: 'Serif', // O una fuente manuscrita si tienes
            letterSpacing: -1,
          ),
        ),
        const Text(
          'El sabor de Italia en tu puerta',
          style: TextStyle(
            color: PizzaColors.textSecondary,
            fontSize: 16,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildFields() {
    // Definimos un estilo común para los inputs si tus CustomTextField lo permiten
    return Column(
      children: [
        CustomTextField(
          controller: _emailCtrl,
          label: 'Tu correo pizzero',
          keyboardType: TextInputType.emailAddress,
          // Cambié iconos a outlines más finos
          prefixIcon: const Icon(Icons.alternate_email_rounded,
              color: PizzaColors.textSecondary),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Dinos tu correo para el pedido';
            if (!v.contains('@')) return 'Ese correo no parece correcto';
            return null;
          },
        ),
        const SizedBox(height: 20), // Un poco más de espacio
        CustomTextField(
          controller: _passwordCtrl,
          label: 'Contraseña secreta',
          obscureText: _obscure,
          prefixIcon: const Icon(Icons.lock_open_rounded,
              color: PizzaColors.textSecondary),
          suffixIcon: IconButton(
            icon: Icon(
              _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: PizzaColors.textSecondary.withOpacity(0.5),
              size: 22,
            ),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Necesitamos tu contraseña';
            if (v.length < 6) return 'Debe tener al menos 6 "ingredientes" (caracteres)';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildInactivityNote() {
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.av_timer_rounded,
              size: 14, color: PizzaColors.textSecondary.withOpacity(0.6)),
          const SizedBox(width: 4),
          Text(
            'La sesión se enfría en ${kInactivitySeconds}s',
            style: TextStyle(
                color: PizzaColors.textSecondary.withOpacity(0.6),
                fontSize: 12,
                fontStyle: FontStyle.italic),
          ),
        ],
      ),
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
          const Icon(Icons.sentiment_very_dissatisfied,
              color: PizzaColors.primaryRed, size: 20),
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

  Widget _buildRegisterLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '¿Nuevo en la pizzería?',
          style: TextStyle(color: PizzaColors.textSecondary, fontSize: 14),
        ),
        TextButton(
          onPressed: () => context.push('/register'),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Crea tu cuenta',
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

  // Rediseño visual de la nota de seguridad (menos técnica, más sutil)
  Widget _buildSecurityNoteVisual() {
    return Opacity(
      opacity: 0.5, // Muy sutil
      child: Column(
        children: [
          const Icon(Icons.verified_user_outlined,
              size: 18, color: PizzaColors.textSecondary),
          const SizedBox(height: 6),
          Text(
            'Tus datos están seguros con nosotros.\nUsamos encriptación de grado horno artesanal (AES-256).',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: PizzaColors.textSecondary,
                fontSize: 11,
                fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}