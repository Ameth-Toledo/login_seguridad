import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../services/wipe_events.dart';
import '../../../../services/notification_service.dart';
import '../../../security/secure_data_provider.dart';

// ─── Datos simulados de Seguridad de la Información ──────────────────────────

class _ConceptoSec {
  final String titulo;
  final String dominio;
  final int impacto;
  final bool esDefensa;
  final String criticidad;
  final IconData icono;
  final String descripcion;

  const _ConceptoSec({
    required this.titulo,
    required this.dominio,
    required this.impacto,
    required this.esDefensa,
    required this.criticidad,
    required this.icono,
    required this.descripcion,
  });
}

const _conceptos = [
  _ConceptoSec(
    titulo: 'Phishing',
    dominio: 'Ingeniería Social',
    impacto: 95,
    esDefensa: false,
    criticidad: 'Crítica',
    icono: Icons.phishing_rounded,
    descripcion:
    'Técnica de engaño donde un atacante se hace pasar por una entidad de confianza para robar credenciales o datos sensibles.',
  ),
  _ConceptoSec(
    titulo: 'Autenticación Multifactor (MFA)',
    dominio: 'Control de Acceso',
    impacto: 90,
    esDefensa: true,
    criticidad: 'Alta',
    icono: Icons.vpn_key_outlined,
    descripcion:
    'Mecanismo de seguridad que requiere dos o más métodos de verificación para acceder a un sistema, aplicación o cuenta.',
  ),
  _ConceptoSec(
    titulo: 'Ransomware',
    dominio: 'Malware',
    impacto: 99,
    esDefensa: false,
    criticidad: 'Crítica',
    icono: Icons.lock_clock_outlined,
    descripcion:
    'Software malicioso que cifra los archivos de la víctima y exige el pago de un rescate para restaurar el acceso.',
  ),
  _ConceptoSec(
    titulo: 'Zero Trust',
    dominio: 'Arquitectura',
    impacto: 85,
    esDefensa: true,
    criticidad: 'Media',
    icono: Icons.shield_outlined,
    descripcion:
    'Modelo de seguridad que asume que ninguna entidad, interna o externa, es confiable por defecto. Todo debe ser verificado.',
  ),
  _ConceptoSec(
    titulo: 'Ataque DDoS',
    dominio: 'Redes',
    impacto: 75,
    esDefensa: false,
    criticidad: 'Alta',
    icono: Icons.wifi_tethering_error_rounded,
    descripcion:
    'Ataque de Denegación de Servicio Distribuido. Inunda un servidor con tráfico masivo para hacerlo inaccesible a los usuarios.',
  ),
  _ConceptoSec(
    titulo: 'Cifrado de Extremo a Extremo',
    dominio: 'Criptografía',
    impacto: 80,
    esDefensa: true,
    criticidad: 'Alta',
    icono: Icons.enhanced_encryption_outlined,
    descripcion:
    'Método de comunicación donde solo los usuarios que se comunican pueden leer los mensajes. Previene la interceptación.',
  ),
  _ConceptoSec(
    titulo: 'Inyección SQL',
    dominio: 'Vulnerabilidades Web',
    impacto: 88,
    esDefensa: false,
    criticidad: 'Alta',
    icono: Icons.bug_report_outlined,
    descripcion:
    'Vulnerabilidad que permite a un atacante interferir en las consultas que hace una aplicación a su base de datos.',
  ),
];

// ─── HomePage ─────────────────────────────────────────────────────────────────

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int? _expandedIndex;
  late final StreamSubscription<void> _wipeSub;

  @override
  void initState() {
    super.initState();
    _wipeSub = wipeEventStream.stream.listen((_) {
      if (mounted) refreshSecureData(ref);
    });
  }

  @override
  void dispose() {
    _wipeSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(auth),
                _buildSecurityScoreCard(),
                // ── Sección de datos sensibles ──────────────────────────────
                const _SecureDataSection(),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    'Glosario de Conceptos',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _conceptos.length,
                    itemBuilder: (_, i) => _buildConceptCard(i, _conceptos[i]),
                  ),
                ),
              ],
            ),
          ),
          // ── Timer discreto ──────────────────────────────────────────────
          if (auth.timerActive)
            Positioned(
              right: 12,
              bottom: 12,
              child: _InactivityBadge(
                remaining: auth.remainingSeconds,
                total: kInactivitySeconds,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(AuthState auth) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola, ${auth.user?.nombre.split(' ').first ?? 'Usuario'} 🛡️',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 14),
                ),
                const Text(
                  'Panel de Seguridad',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => ref.read(authProvider.notifier).logout(),
            icon: const Icon(Icons.logout_rounded,
                color: AppColors.textSecondary, size: 20),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityScoreCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Índice de Salud de Red',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 4),
                const Text(
                  '82 / 100',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _miniStat('3 Defensas Activas', true),
              const SizedBox(height: 6),
              _miniStat('4 Amenazas Vistas', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, bool isGood) {
    final color = isGood ? AppColors.accent : AppColors.error;
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w600))
    );
  }

  Widget _buildConceptCard(int index, _ConceptoSec concepto) {
    final isExpanded = _expandedIndex == index;

    return GestureDetector(
      onTap: () =>
          setState(() => _expandedIndex = isExpanded ? null : index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(isExpanded ? 16 : 12),
        decoration: BoxDecoration(
          color: isExpanded ? AppColors.surfaceVariant : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isExpanded
                ? (concepto.esDefensa
                ? AppColors.accent.withValues(alpha: 0.3)
                : AppColors.error.withValues(alpha: 0.2))
                : const Color(0xFF1F1F1F),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (concepto.esDefensa
                        ? AppColors.accent
                        : AppColors.error)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(concepto.icono,
                      size: 18,
                      color: concepto.esDefensa
                          ? AppColors.accent
                          : AppColors.error),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(concepto.titulo,
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                      Text(concepto.dominio,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                Text(
                  'Impacto: ${concepto.impacto}',
                  style: TextStyle(
                    color: concepto.esDefensa
                        ? AppColors.accent
                        : AppColors.error,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              ],
            ),
            if (isExpanded) ...[
              const SizedBox(height: 14),
              const Divider(color: Color(0xFF2A2A2A), height: 1),
              const SizedBox(height: 14),
              Text(
                concepto.descripcion,
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _detailChip(
                    concepto.esDefensa
                        ? Icons.verified_user_outlined
                        : Icons.warning_amber_rounded,
                    concepto.esDefensa ? 'Defensa' : 'Amenaza',
                  ),
                  const SizedBox(width: 8),
                  _detailChip(Icons.speed_rounded,
                      'Severidad: ${concepto.criticidad}'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detailChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}

// ─── Sección de Almacén Encriptado + Remote Wipe ────────────────────────────

class _SecureDataSection extends ConsumerWidget {
  const _SecureDataSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(secureDataProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lock_outline_rounded,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              const Text(
                'Almacén Encriptado',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              asyncData.when(
                data: (data) {
                  final hasData = data.values.any((v) => v != null);
                  return _StatusChip(active: hasData);
                },
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          asyncData.when(
            data: (data) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DataCard(data: data),
                const SizedBox(height: 12),
                // ── Sección de Remote Wipe ──────────────────────────────
                const _RemoteWipeSection(),
              ],
            ),
            loading: () => const _DataCardSkeleton(),
            error: (e, _) => Text('Error: $e',
                style: const TextStyle(
                    color: AppColors.error, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool active;
  const _StatusChip({required this.active});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.accent : AppColors.error;
    final label = active ? 'Datos presentes' : 'Datos eliminados';
    final icon = active ? Icons.verified_outlined : Icons.delete_sweep_outlined;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _DataCard extends StatelessWidget {
  final Map<String, String?> data;
  const _DataCard({required this.data});

  String _mask(String? value, String key) {
    if (value == null) return '— eliminado —';
    if (key == 'Credit Card') {
      return '**** **** **** ${value.length >= 4 ? value.substring(value.length - 4) : value}';
    }
    if (key == 'Password Hash') return '••••••••••••';
    if (value.length <= 8) return value;
    return '${value.substring(0, 8)}••••';
  }

  @override
  Widget build(BuildContext context) {
    final fields = data.entries
        .where((e) => e.key != 'User ID')
        .toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F1F1F)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < fields.length; i++) ...[
            _FieldRow(
              label: fields[i].key,
              value: _mask(fields[i].value, fields[i].key),
              isPresent: fields[i].value != null,
            ),
            if (i < fields.length - 1)
              const Divider(
                  color: Color(0xFF1F1F1F), height: 16, thickness: 0.5),
          ],
          const Divider(color: Color(0xFF1F1F1F), height: 16, thickness: 0.5),
          _FcmTokenRow(userId: data['User ID']),
        ],
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isPresent;

  const _FieldRow({
    required this.label,
    required this.value,
    required this.isPresent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isPresent ? Icons.circle : Icons.circle_outlined,
          size: 7,
          color: isPresent
              ? AppColors.accent
              : AppColors.error.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 100,
          child: Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: isPresent
                  ? AppColors.textPrimary
                  : AppColors.error.withValues(alpha: 0.7),
              fontSize: 12,
              fontFamily: 'monospace',
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _FcmTokenRow extends StatelessWidget {
  final String? userId;
  const _FcmTokenRow({this.userId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: userId == null
          ? null
          : () {
        Clipboard.setData(ClipboardData(text: userId!));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User ID copiado — úsalo en target_user_id'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Row(
        children: [
          const Icon(Icons.fingerprint, size: 7, color: AppColors.warning),
          const SizedBox(width: 10),
          const SizedBox(
            width: 100,
            child: Text('User ID',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
          ),
          Expanded(
            child: Text(
              userId ?? '— eliminado —',
              style: TextStyle(
                color: userId != null
                    ? AppColors.warning
                    : AppColors.error.withValues(alpha: 0.7),
                fontSize: 12,
                fontFamily: 'monospace',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (userId != null)
            const Icon(Icons.copy_outlined,
                size: 12, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _DataCardSkeleton extends StatelessWidget {
  const _DataCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

// ─── Sección Remote Wipe ──────────────────────────────────────────────────────

class _RemoteWipeSection extends ConsumerStatefulWidget {
  const _RemoteWipeSection();

  @override
  ConsumerState<_RemoteWipeSection> createState() => _RemoteWipeSectionState();
}

class _RemoteWipeSectionState extends ConsumerState<_RemoteWipeSection> {
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;

  void _clearMessage() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _message = null);
    });
  }

  Future<void> _requestRemoteWipe() async {
    final auth = ref.read(authProvider);
    if (auth.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No estás autenticado')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final notificationService = NotificationService();
    final response = await notificationService.requestRemoteWipe(
      userId: auth.user!.id.toString(),
      authToken: auth.user!.token,
      reason: 'Solicitud manual desde app mobile',
    );

    setState(() {
      _isLoading = false;
      _message = response.message;
      _isSuccess = response.success;
    });

    _clearMessage();

    if (response.success) {
      // Opcional: mostrar SnackBar adicional
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              '🔔 Notificación FCM enviada — los datos se eliminarán cuando llegue',
            ),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.accent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.delete_forever_outlined,
                  size: 14, color: AppColors.error),
              const SizedBox(width: 8),
              const Text(
                'Eliminar datos remotamente',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Solicita que se eliminen todos los datos sensibles de este dispositivo mediante una notificación remota segura.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          if (_message != null)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isSuccess
                    ? AppColors.accent.withValues(alpha: 0.12)
                    : AppColors.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _isSuccess ? Icons.check_circle : Icons.error,
                    size: 14,
                    color: _isSuccess ? AppColors.accent : AppColors.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _message!,
                      style: TextStyle(
                        color: _isSuccess ? AppColors.accent : AppColors.error,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _requestRemoteWipe,
              icon: _isLoading
                  ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor: AlwaysStoppedAnimation(AppColors.error),
                ),
              )
                  : const Icon(Icons.send_rounded, size: 14),
              label: Text(
                _isLoading ? 'Enviando...' : 'Solicitar Wipe Remoto',
                style: const TextStyle(fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Badge de inactividad ─────────────────────────────────────────────────────

class _InactivityBadge extends StatelessWidget {
  final int remaining;
  final int total;

  const _InactivityBadge({required this.remaining, required this.total});

  Color get _color {
    final ratio = total > 0 ? remaining / total : 0.0;
    if (ratio > 0.5) return AppColors.textSecondary;
    if (ratio > 0.2) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 10, color: _color),
          const SizedBox(width: 4),
          Text(
            '${remaining}s',
            style: TextStyle(
              color: _color,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}