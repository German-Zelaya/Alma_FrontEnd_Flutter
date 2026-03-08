// ════════════════════════════════════════════════════════════
//  DEV 3 — DASHBOARD / PANTALLA DE INICIO
//  Integra: GET /cycle/current · GET /tasks · GET /journal
//           GET /habits/summary · GET /goals
// ════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _navIndex = 0;

  // TODO: Reemplazar con datos reales de la API
  final _userName = 'Sofía';
  final _currentPhase = 'Fase Lútea';
  final _phaseDay = 21;
  final _phaseTip = 'Es un buen momento para el descanso y la reflexión profunda.';
  final _totalTasks = 5;
  final _completedTasks = 2;
  final _growthPoints = 1;
  int _streakDays = 7;

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildCycleCard(),
              const SizedBox(height: 20),
              _buildDaySummary(),
              const SizedBox(height: 20),
              _buildQuickActions(),
              const SizedBox(height: 20),
              _buildUpcomingTasks(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _navIndex,
        onTap: (i) {
          setState(() => _navIndex = i);
          // TODO: Navegar entre módulos
          switch (i) {
            case 1: Navigator.pushNamed(context, '/agenda'); break;
            case 2: Navigator.pushNamed(context, '/growth'); break;
            case 3: Navigator.pushNamed(context, '/settings'); break;
          }
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Hola, $_userName ', style: AppTextStyles.heading1),
                Image.asset('assets/images/logo.png', width: 30, height: 30),
              ],
            ),
            Text(_currentDate(), style: AppTextStyles.bodySecondary),
          ],
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/settings'),
          child: Container(
            width: 44, height: 44,
            decoration: AppDecorations.primaryContainer,
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildCycleCard() {
    // TODO: Consumir GET /cycle/current → { phase, day, recommendations }
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.wb_sunny_rounded, color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text('Día $_phaseDay · $_currentPhase', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('💡 Tip del día', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(_phaseTip, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(height: 6),
              Text('$_streakDays días', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              const Text('racha', style: TextStyle(color: Colors.white60, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDaySummary() {
    // TODO: Obtener datos de GET /tasks y GET /habits/summary
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Resumen del día'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: AppInfoCard(label: 'Total tareas', value: '$_totalTasks', icon: const Icon(Icons.task_alt_rounded, color: AppColors.primary, size: 20))),
            const SizedBox(width: 12),
            Expanded(child: AppInfoCard(label: 'Completadas', value: '$_completedTasks', color: AppColors.badgeLow, icon: const Icon(Icons.check_circle_outline_rounded, color: AppColors.badgeLow, size: 20))),
            const SizedBox(width: 12),
            Expanded(child: AppInfoCard(label: 'Puntos', value: '$_growthPoints 🌟', icon: const Icon(Icons.star_rounded, color: AppColors.badgeMedium, size: 20))),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      _QuickAction('Diario', Icons.book_outlined, AppColors.primary, '/diary'),
      _QuickAction('Hábitos', Icons.check_box_outlined, AppColors.badgeLow, '/habits'),
      _QuickAction('Metas', Icons.flag_outlined, AppColors.badgeMedium, '/goals'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Acceso rápido'),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: actions.map((a) => _buildActionButton(a)).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButton(_QuickAction action) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, action.route),
      child: Column(
        children: [
          Container(
            width: 62, height: 62,
            decoration: BoxDecoration(
              color: action.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: action.color.withOpacity(0.25)),
            ),
            child: Icon(action.icon, color: action.color, size: 28),
          ),
          const SizedBox(height: 6),
          Text(action.label, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildUpcomingTasks() {
    // TODO: Consumir GET /tasks y mostrar las primeras 3
    final tasks = [
      ('Sesión de meditación matutina', BadgeType.high),
      ('Registrar hábitos del día', BadgeType.medium),
      ('Escribir en el diario', BadgeType.low),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: 'Tareas pendientes', action: 'Ver todas', onAction: () => Navigator.pushNamed(context, '/agenda')),
        const SizedBox(height: 12),
        ...tasks.map((t) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TaskItem(
            title: t.$1,
            priority: t.$2,
            completed: false,
            onToggle: () {},
            onDelete: () {},
          ),
        )),
      ],
    );
  }

  String _currentDate() {
    final now = DateTime.now();
    final months = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
    final days = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];
    return '${days[now.weekday - 1]}, ${now.day} de ${months[now.month - 1]}';
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final String route;
  _QuickAction(this.label, this.icon, this.color, this.route);
}
