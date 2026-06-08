import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../../../shared/theme/app_colors.dart';

// ─── Datos simulados ──────────────────────────────────────────────────────────

class _Tx {
  final String titulo;
  final String categoria;
  final double monto;
  final bool esIngreso;
  final String fecha;
  final IconData icono;

  const _Tx({
    required this.titulo,
    required this.categoria,
    required this.monto,
    required this.esIngreso,
    required this.fecha,
    required this.icono,
  });
}

const _transacciones = [
  _Tx(titulo: 'Salario mensual', categoria: 'Ingresos', monto: 18500, esIngreso: true, fecha: 'Hoy', icono: Icons.work_outline_rounded),
  _Tx(titulo: 'Supermercado Walmart', categoria: 'Alimentación', monto: 1240, esIngreso: false, fecha: 'Hoy', icono: Icons.shopping_cart_outlined),
  _Tx(titulo: 'Netflix', categoria: 'Entretenimiento', monto: 219, esIngreso: false, fecha: 'Ayer', icono: Icons.play_circle_outline_rounded),
  _Tx(titulo: 'Freelance diseño', categoria: 'Ingresos', monto: 4500, esIngreso: true, fecha: 'Lun', icono: Icons.brush_outlined),
  _Tx(titulo: 'Gasolina', categoria: 'Transporte', monto: 800, esIngreso: false, fecha: 'Lun', icono: Icons.local_gas_station_outlined),
  _Tx(titulo: 'Restaurante', categoria: 'Alimentación', monto: 560, esIngreso: false, fecha: 'Dom', icono: Icons.restaurant_outlined),
  _Tx(titulo: 'Spotify', categoria: 'Entretenimiento', monto: 99, esIngreso: false, fecha: 'Sáb', icono: Icons.music_note_outlined),
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
                _buildBalanceCard(),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Text(
                    'Movimientos recientes',
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
                    itemCount: _transacciones.length,
                    itemBuilder: (_, i) =>
                        _buildTxCard(i, _transacciones[i]),
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
                  'Hola, ${auth.user?.nombre.split(' ').first ?? ''} 👋',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const Text(
                  'Mis finanzas',
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

  // ── Tarjeta de balance ─────────────────────────────────────────────────────

  Widget _buildBalanceCard() {
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
                const Text('Balance total',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 4),
                const Text(
                  '\$20,082',
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
              _miniStat('+\$23,000', true),
              const SizedBox(height: 6),
              _miniStat('-\$2,918', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, bool positive) {
    final color = positive ? AppColors.accent : AppColors.error;
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

  // ── Tarjeta de transacción expandible ──────────────────────────────────────

  Widget _buildTxCard(int index, _Tx tx) {
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
                ? (tx.esIngreso
                ? AppColors.accent.withOpacity(0.3)
                : AppColors.error.withOpacity(0.2))
                : const Color(0xFF1F1F1F),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            // Fila principal
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (tx.esIngreso ? AppColors.accent : AppColors.error)
                        .withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(tx.icono,
                      size: 18,
                      color: tx.esIngreso
                          ? AppColors.accent
                          : AppColors.error),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tx.titulo,
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                      Text(tx.categoria,
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
                      '${tx.esIngreso ? '+' : '-'}\$${tx.monto.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: tx.esIngreso
                            ? AppColors.accent
                            : AppColors.error,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(tx.fecha,
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11)),
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
            // Detalle expandible
            if (isExpanded) ...[
              const SizedBox(height: 14),
              const Divider(color: Color(0xFF2A2A2A), height: 1),
              const SizedBox(height: 14),
              Row(
                children: [
                  _detailChip(Icons.category_outlined, tx.categoria),
                  const SizedBox(width: 8),
                  _detailChip(Icons.calendar_today_outlined, tx.fecha),
                  const SizedBox(width: 8),
                  _detailChip(
                    tx.esIngreso
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                    tx.esIngreso ? 'Ingreso' : 'Egreso',
                  ),
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
    if (ratio > 0.5) return AppColors.textSecondary;   // gris — no llamativo
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