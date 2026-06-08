import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../../../shared/theme/app_colors.dart';
import 'dart:ui'; // Para FontFeature

// ─── Datos simulados de Seguridad de la Información ──────────────────────────

class _ConceptoSec {
  final String titulo;
  final String dominio;
  final int impacto; // Nivel del 1 al 100
  final bool esDefensa; // true = Defensa (bueno), false = Amenaza (malo)
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
    descripcion: 'Técnica de engaño donde un atacante se hace pasar por una entidad de confianza para robar credenciales o datos sensibles.',
  ),
  _ConceptoSec(
    titulo: 'Autenticación Multifactor (MFA)',
    dominio: 'Control de Acceso',
    impacto: 90,
    esDefensa: true,
    criticidad: 'Alta',
    icono: Icons.vpn_key_outlined,
    descripcion: 'Mecanismo de seguridad que requiere dos o más métodos de verificación para acceder a un sistema, aplicación o cuenta.',
  ),
  _ConceptoSec(
    titulo: 'Ransomware',
    dominio: 'Malware',
    impacto: 99,
    esDefensa: false,
    criticidad: 'Crítica',
    icono: Icons.lock_clock_outlined,
    descripcion: 'Software malicioso que cifra los archivos de la víctima y exige el pago de un rescate para restaurar el acceso.',
  ),
  _ConceptoSec(
    titulo: 'Zero Trust',
    dominio: 'Arquitectura',
    impacto: 85,
    esDefensa: true,
    criticidad: 'Media',
    icono: Icons.shield_outlined,
    descripcion: 'Modelo de seguridad que asume que ninguna entidad, interna o externa, es confiable por defecto. Todo debe ser verificado.',
  ),
  _ConceptoSec(
    titulo: 'Ataque DDoS',
    dominio: 'Redes',
    impacto: 75,
    esDefensa: false,
    criticidad: 'Alta',
    icono: Icons.wifi_tethering_error_rounded,
    descripcion: 'Ataque de Denegación de Servicio Distribuido. Inunda un servidor con tráfico masivo para hacerlo inaccesible a los usuarios.',
  ),
  _ConceptoSec(
    titulo: 'Cifrado de Extremo a Extremo',
    dominio: 'Criptografía',
    impacto: 80,
    esDefensa: true,
    criticidad: 'Alta',
    icono: Icons.enhanced_encryption_outlined,
    descripcion: 'Método de comunicación donde solo los usuarios que se comunican pueden leer los mensajes. Previene la interceptación.',
  ),
  _ConceptoSec(
    titulo: 'Inyección SQL',
    dominio: 'Vulnerabilidades Web',
    impacto: 88,
    esDefensa: false,
    criticidad: 'Alta',
    icono: Icons.bug_report_outlined,
    descripcion: 'Vulnerabilidad que permite a un atacante interferir en las consultas que hace una aplicación a su base de datos.',
  ),
];

// ─── HomePage ─────────────────────────────────────────────────────────────────

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  // Índice de la tarjeta expandida. null = ninguna.
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Contenido principal ──────────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(auth),
                _buildSecurityScoreCard(),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
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
                    itemBuilder: (_, i) =>
                        _buildConceptCard(i, _conceptos[i]),
                  ),
                ),
              ],
            ),
          ),
          // ── Timer discreto en esquina inferior derecha ───────────────────
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

  // ── Header ─────────────────────────────────────────────────────────────────

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
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
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

  // ── Tarjeta de Estado de Seguridad ─────────────────────────────────────────

  Widget _buildSecurityScoreCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border:
        Border.all(color: AppColors.accent.withOpacity(0.2), width: 1.5),
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
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  // ── Tarjeta de concepto expandible ─────────────────────────────────────────

  Widget _buildConceptCard(int index, _ConceptoSec concepto) {
    final isExpanded = _expandedIndex == index;

    return GestureDetector(
      onTap: () => setState(
              () => _expandedIndex = isExpanded ? null : index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(isExpanded ? 16 : 12),
        decoration: BoxDecoration(
          color: isExpanded
              ? AppColors.surfaceVariant
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isExpanded
                ? (concepto.esDefensa
                ? AppColors.accent.withOpacity(0.3)
                : AppColors.error.withOpacity(0.2))
                : const Color(0xFF1F1F1F),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fila principal visible siempre
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (concepto.esDefensa ? AppColors.accent : AppColors.error)
                        .withOpacity(0.12),
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
                              color: AppColors.textSecondary,
                              fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
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
                  ],
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
            // Detalle expandible (Definición y etiquetas)
            if (isExpanded) ...[
              const SizedBox(height: 14),
              const Divider(color: Color(0xFF2A2A2A), height: 1),
              const SizedBox(height: 14),
              Text(
                concepto.descripcion,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _detailChip(
                      concepto.esDefensa ? Icons.verified_user_outlined : Icons.warning_amber_rounded,
                      concepto.esDefensa ? 'Defensa' : 'Amenaza'
                  ),
                  const SizedBox(width: 8),
                  _detailChip(Icons.speed_rounded, 'Severidad: ${concepto.criticidad}'),
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

// ─── Badge de inactividad (discreto, esquina inferior derecha) ────────────────

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
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant.withOpacity(0.85),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _color.withOpacity(0.3)),
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
      ),
    );
  }
}