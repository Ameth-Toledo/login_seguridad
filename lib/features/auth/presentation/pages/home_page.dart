import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../../../shared/theme/app_colors.dart';
import 'dart:ui'; // Para FontFeature

// --- CONSTANTES DE ESTILO PARA LA PIZZERÍA ---
class PizzaColors {
  static const Color primaryRed = Color(0xFFD32F2F); // Rojo Pomodoro
  static const Color accentOrange = Color(0xFFFFA000); // Queso/Horno
  static const Color backgroundCrema = Color(0xFFFFF8E1); // Masa/Harina suave
  static const Color textDark = Color(0xFF3E2723); // Marrón corteza oscuro
  static const Color textSecondary = Color(0xFF795548);
}

// Supongamos que esta constante viene de tu configuración original
const int kInactivitySeconds = 120;

// ─── Datos de la Pizzería (Glosario Gourmet) ──────────────────────────

class _ConceptoPizza {
  final String titulo;
  final String categoria;
  final int popularidad; // Porcentaje de pedidos (1 al 100)
  final bool esPicante;
  final String tiempoPreparacion;
  final IconData icono;
  final String descripcion;

  const _ConceptoPizza({
    required this.titulo,
    required this.categoria,
    required this.popularidad,
    required this.esPicante,
    required this.tiempoPreparacion,
    required this.icono,
    required this.descripcion,
  });
}

const _especialidades = [
  _ConceptoPizza(
    titulo: 'Masa Madre de 48 Horas',
    categoria: 'Secretos de Cocina',
    popularidad: 98,
    esPicante: false,
    tiempoPreparacion: 'Alta Dedicación',
    icono: Icons.bakery_dining_rounded,
    descripcion: 'Nuestra base artesanal fermentada lentamente en frío. Aporta una textura ligera, alveolada y de fácil digestión.',
  ),
  _ConceptoPizza(
    titulo: 'Pizza Pepperoni Suprema',
    categoria: 'Especialidades Carnívoras',
    popularidad: 95,
    esPicante: true,
    tiempoPreparacion: '12 min',
    icono: Icons.local_pizza_rounded,
    descripcion: 'Doble porción de pepperoni premium madurado, mozzarella hilada y un toque sutil de pepperoncino sobre salsa pomodoro.',
  ),
  _ConceptoPizza(
    titulo: 'Margherita con Mozzarella di Bufala',
    categoria: 'Clásicas Italianas',
    popularidad: 90,
    esPicante: false,
    tiempoPreparacion: '10 min',
    icono: Icons.eco_rounded,
    descripcion: 'La reina de Nápoles. Salsa de tomates San Marzano, auténtica mozzarella de búfala, albahaca fresca y aceite de oliva virgen.',
  ),
  _ConceptoPizza(
    titulo: 'Salsa Pomodoro San Marzano',
    categoria: 'Ingredientes Base',
    popularidad: 88,
    esPicante: false,
    tiempoPreparacion: 'Preparación diaria',
    icono: Icons.soup_kitchen_rounded,
    descripcion: 'Tomates cultivados a las faldas del Vesubio, triturados a mano y sazonados con sal marina y albahaca. Cero conservantes.',
  ),
  _ConceptoPizza(
    titulo: 'Cuatro Quesos de la Casa',
    categoria: 'Especialidades Blancas',
    popularidad: 85,
    esPicante: false,
    tiempoPreparacion: '11 min',
    icono: Icons.restaurant_rounded, // Reemplazado por uno válido
    descripcion: 'Una rica amalgama de Mozzarella, Gorgonzola DOP, Parmigiano Reggiano rallado e hilos de queso Provolone ahumado.',
  ),
  _ConceptoPizza(
    titulo: 'Aceite de Oliva al Peperoncino',
    categoria: 'Acompañamientos',
    popularidad: 78,
    esPicante: true,
    tiempoPreparacion: 'Inmediato',
    icono: Icons.opacity_rounded, // Corregido el carácter extraño
    descripcion: 'Aceite de oliva extra virgen macerado artesanalmente con copos de chiles secos picantes, ideal para los bordes (cornicione).',
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

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: PizzaColors.backgroundCrema,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // El Header ahora lleva el timer integrado elegantemente
            _buildHeader(auth),
            _buildOvenStatusCard(),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text(
                'Nuestra Enciclopedia Pizzera',
                style: TextStyle(
                  color: PizzaColors.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _especialidades.length,
                itemBuilder: (_, i) => _buildConceptCard(i, _especialidades[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header (Ahora con el Timer integrado arriba) ───────────────────────────

  Widget _buildHeader(AuthState auth) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Ciao, ${auth.user?.nombre.split(' ').first ?? 'Pizzero'}! 🍕',
                  style: const TextStyle(
                    color: PizzaColors.textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(
                  'Bella Napoli',
                  style: TextStyle(
                    color: PizzaColors.primaryRed,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Serif',
                  ),
                ),
              ],
            ),
          ),

          // 💡 NUEVA UBICACIÓN: El Badge de tiempo ahora aparece aquí de forma sutil
          if (auth.timerActive) ...[
            _InactivityBadge(
              remaining: auth.remainingSeconds,
              total: kInactivitySeconds,
            ),
            const SizedBox(width: 8),
          ],

          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => ref.read(authProvider.notifier).logout(),
              icon: const Icon(Icons.logout_rounded,
                  color: PizzaColors.primaryRed, size: 20),
              tooltip: 'Salir de la cocina',
            ),
          ),
        ],
      ),
    );
  }

  // ── Tarjeta de Estado de la Cocina / Horno ─────────────────────────────────

  Widget _buildOvenStatusCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: PizzaColors.textDark.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Estado del Horno de Piedra',
                    style: TextStyle(
                        color: PizzaColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '450°C Óptimo',
                      style: TextStyle(
                        color: PizzaColors.textDark,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _miniStat('Artesanal', true),
              const SizedBox(height: 6),
              _miniStat('Ingredientes 100% Frescos', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, bool isPrimary) {
    final color = isPrimary ? PizzaColors.primaryRed : PizzaColors.accentOrange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  // ── Tarjeta de Especialidad Expandible ──────────────────────────────────────

  Widget _buildConceptCard(int index, _ConceptoPizza especialidad) {
    final isExpanded = _expandedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _expandedIndex = isExpanded ? null : index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isExpanded
                ? PizzaColors.primaryRed.withOpacity(0.3)
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: PizzaColors.textDark.withOpacity(isExpanded ? 0.08 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: PizzaColors.primaryRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(especialidad.icono,
                      size: 22, color: PizzaColors.primaryRed),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(especialidad.titulo,
                          style: const TextStyle(
                              color: PizzaColors.textDark,
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                      Text(especialidad.categoria,
                          style: const TextStyle(
                              color: PizzaColors.textSecondary,
                              fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '⭐ ${especialidad.popularidad}%',
                      style: const TextStyle(
                        color: PizzaColors.accentOrange,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Pedidos', style: TextStyle(fontSize: 10, color: PizzaColors.textSecondary))
                  ],
                ),
                const SizedBox(width: 4),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: PizzaColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
            if (isExpanded) ...[
              const SizedBox(height: 14),
              const Divider(color: Color(0xFFEEEEEE), height: 1),
              const SizedBox(height: 14),
              Text(
                especialidad.descripcion,
                style: const TextStyle(
                  color: PizzaColors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _detailChip(
                      especialidad.esPicante ? Icons.local_fire_department_rounded : Icons.restaurant_rounded,
                      especialidad.esPicante ? 'Picante' : 'Suave',
                      especialidad.esPicante ? Colors.red : PizzaColors.textSecondary
                  ),
                  const SizedBox(width: 8),
                  _detailChip(Icons.schedule_rounded, especialidad.tiempoPreparacion, PizzaColors.textSecondary),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detailChip(IconData icon, String label, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: PizzaColors.backgroundCrema.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: textColor, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─── Badge de inactividad (Ahora rediseñado como un bonito Chip de barra superior) ───

class _InactivityBadge extends StatelessWidget {
  final int remaining;
  final int total;

  const _InactivityBadge({required this.remaining, required this.total});

  Color get _color {
    final ratio = total > 0 ? remaining / total : 0.0;
    if (ratio > 0.5) return Colors.green;
    if (ratio > 0.2) return PizzaColors.accentOrange;
    return PizzaColors.primaryRed;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _color.withOpacity(0.4), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_fire_department_outlined, size: 14, color: _color),
            const SizedBox(width: 4),
            Text(
              '${remaining}s',
              style: TextStyle(
                color: PizzaColors.textDark,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}