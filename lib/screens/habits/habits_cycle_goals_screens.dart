// ════════════════════════════════════════════════════════════
//  DEV 2 — HÁBITOS, CICLO MENSTRUAL Y METAS ADAPTATIVAS
// ════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

// ─── RASTREADOR DE HÁBITOS ────────────────────────────────
// POST /habits/log · GET /habits/summary (resumen IA Bedrock)
class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});
  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  // TODO: Cargar estado de GET /habits/log?date=today
  final Map<String, bool> _habits = {
    'Sueño (7-8h)': false,
    'Agua (2L)': true,
    'Ejercicio': false,
    'Meditación': true,
    'Alimentación saludable': false,
    'Sin pantallas 1h antes': false,
  };

  final Map<String, _HabitMeta> _habitsMeta = {
    'Sueño (7-8h)': _HabitMeta(Icons.bedtime_rounded, AppColors.primary),
    'Agua (2L)': _HabitMeta(Icons.water_drop_rounded, Color(0xFF3B82F6)),
    'Ejercicio': _HabitMeta(Icons.fitness_center_rounded, AppColors.badgeLow),
    'Meditación': _HabitMeta(Icons.self_improvement_rounded, Color(0xFF8B5CF6)),
    'Alimentación saludable': _HabitMeta(Icons.restaurant_rounded, AppColors.badgeMedium),
    'Sin pantallas 1h antes': _HabitMeta(Icons.phone_disabled_rounded, AppColors.badgeHigh),
  };

  String? _weeklySummary;

  Future<void> _loadWeeklySummary() async {
    // TODO: Llamar GET /habits/summary → respuesta Bedrock
    setState(() => _weeklySummary = 'Esta semana mantuviste una buena racha de hidratación y meditación. Te recomiendo enfocarte en el sueño, ya que durante la fase lútea es crucial para tu bienestar emocional. 🌙');
  }

  Future<void> _toggleHabit(String key, bool value) async {
    setState(() => _habits[key] = value);
    // TODO: POST /habits/log con { habit: key, value: value, date: today }
  }

  @override
  Widget build(BuildContext context) {
    final completed = _habits.values.where((v) => v).length;
    final total = _habits.length;

    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        title: const Text('Mis Hábitos'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progreso del día
            AppCard(
              useGradient: true,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Progreso de hoy', style: AppTextStyles.bodySecondary),
                          Text('$completed / $total hábitos', style: AppTextStyles.heading2),
                        ],
                      ),
                      SizedBox(
                        width: 60, height: 60,
                        child: Stack(
                          children: [
                            CircularProgressIndicator(
                              value: completed / total,
                              backgroundColor: AppColors.primaryLight.withOpacity(0.3),
                              color: AppColors.primary,
                              strokeWidth: 6,
                            ),
                            Center(child: Text('${(completed / total * 100).round()}%', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: completed / total,
                    backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Lista de hábitos
            const SectionTitle(title: 'Hábitos del día'),
            const SizedBox(height: 12),
            ..._habits.keys.map((key) {
              final meta = _habitsMeta[key]!;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: HabitCheckItem(
                  label: key,
                  icon: meta.icon,
                  checked: _habits[key]!,
                  color: meta.color,
                  onTap: () => _toggleHabit(key, !_habits[key]!),
                ),
              );
            }),
            const SizedBox(height: 20),

            // Resumen semanal IA
            if (_weeklySummary != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppDecorations.gradientCard,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [
                      Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 18),
                      SizedBox(width: 8),
                      Text('Resumen semanal IA', style: AppTextStyles.heading3),
                    ]),
                    const SizedBox(height: 10),
                    Text(_weeklySummary!, style: AppTextStyles.body.copyWith(height: 1.6)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            AppButton(
              label: _weeklySummary == null ? 'Ver resumen semanal ✨' : 'Actualizar resumen',
              style: AppButtonStyle.outline,
              onPressed: _loadWeeklySummary,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitMeta {
  final IconData icon;
  final Color color;
  _HabitMeta(this.icon, this.color);
}

// ─── CICLO MENSTRUAL ─────────────────────────────────────
// GET /cycle/current → { phase, day, recommendations }
// POST /cycle/log → registrar inicio del ciclo
class CycleScreen extends StatefulWidget {
  const CycleScreen({super.key});
  @override
  State<CycleScreen> createState() => _CycleScreenState();
}

class _CycleScreenState extends State<CycleScreen> {
  // TODO: Obtener de GET /cycle/current
  final _currentPhase = 'Lútea';
  final _currentDay = 21;
  final _cycleLength = 28;
  final _daysUntilNext = 7;

  final _phases = [
    _PhaseInfo('Menstrual', 'Días 1-5', AppColors.phaseMenstrual, Icons.water_drop_rounded,
        'Tu cuerpo necesita descanso y cuidado. Es momento de ser amable contigo misma.'),
    _PhaseInfo('Folicular', 'Días 6-13', AppColors.phaseFolicular, Icons.sunny_snowing,
        'Tu energía aumenta. Es el mejor momento para empezar nuevos proyectos.'),
    _PhaseInfo('Ovulación', 'Días 14-16', AppColors.phaseOvulacion, Icons.brightness_high_rounded,
        'Pico de energía y creatividad. Ideal para presentaciones y conexiones sociales.'),
    _PhaseInfo('Lútea', 'Días 17-28', AppColors.phaseLutea, Icons.nights_stay_rounded,
        'Enfócate en la introspección y en terminar proyectos pendientes.'),
  ];

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        title: const Text('Ciclo Menstrual'),
        actions: [
          TextButton.icon(
            onPressed: _showLogCycle,
            icon: const Icon(Icons.add_rounded, color: AppColors.primary),
            label: const Text('Registrar', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildCycleWheel(),
            const SizedBox(height: 20),
            _buildCurrentPhaseCard(),
            const SizedBox(height: 20),
            const SectionTitle(title: 'Las 4 fases'),
            const SizedBox(height: 12),
            ..._phases.map((p) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _buildPhaseCard(p))),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleWheel() {
    return AppCard(
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 160, height: 160,
                  child: CircularProgressIndicator(
                    value: _currentDay / _cycleLength,
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation(AppColors.phaseLutea),
                    strokeWidth: 16,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Día $_currentDay', style: AppTextStyles.heading2.copyWith(color: AppColors.phaseLutea)),
                    Text('de $_cycleLength', style: AppTextStyles.bodySecondary),
                    const SizedBox(height: 4),
                    Text('Fase $_currentPhase', style: AppTextStyles.caption.copyWith(color: AppColors.phaseLutea, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: AppColors.phaseLutea.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text('Próximo período en $_daysUntilNext días', style: TextStyle(color: AppColors.phaseLutea, fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPhaseCard() {
    final current = _phases.firstWhere((p) => p.name == _currentPhase);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: current.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: current.color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(current.icon, color: current.color),
            const SizedBox(width: 10),
            Text('Fase actual: ${current.name}', style: AppTextStyles.heading3.copyWith(color: current.color)),
          ]),
          const SizedBox(height: 10),
          Text(current.recommendation, style: AppTextStyles.body.copyWith(height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildPhaseCard(_PhaseInfo phase) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: phase.color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(phase.icon, color: phase.color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(phase.name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                Text(phase.days, style: AppTextStyles.caption.copyWith(color: phase.color)),
              ],
            ),
          ),
          if (phase.name == _currentPhase)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: phase.color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
              child: Text('Actual', style: TextStyle(color: phase.color, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  void _showLogCycle() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Registrar ciclo', style: AppTextStyles.heading2),
            const SizedBox(height: 8),
            const Text('¿Cuándo comenzó tu último período?', style: AppTextStyles.bodySecondary),
            const SizedBox(height: 20),
            AppButton(
              label: 'Seleccionar fecha',
              style: AppButtonStyle.outline,
              width: double.infinity,
              icon: const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 18),
              onPressed: () async {
                final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now().subtract(const Duration(days: 30)), lastDate: DateTime.now());
                if (d != null) {
                  // TODO: POST /cycle/log con { startDate: d, cycleLength: 28 }
                  Navigator.pop(context);
                }
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _PhaseInfo {
  final String name, days, recommendation;
  final Color color;
  final IconData icon;
  _PhaseInfo(this.name, this.days, this.color, this.icon, this.recommendation);
}

// ─── METAS ADAPTATIVAS ───────────────────────────────────
// GET /goals · POST /goals/advice (Bedrock + fase del ciclo)
class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});
  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  // TODO: Cargar de GET /goals
  final List<_Goal> _goals = [
    _Goal('Meditar 20 min diarios', 'Bienestar', 0.6, AppColors.primary),
    _Goal('Correr 3 veces por semana', 'Ejercicio', 0.4, AppColors.badgeLow),
    _Goal('Ahorrar \$500 al mes', 'Finanzas', 0.8, AppColors.badgeMedium),
    _Goal('Leer 2 libros al mes', 'Aprendizaje', 0.3, Color(0xFF3B82F6)),
  ];

  void _showCreateGoal() {
    final titleCtrl = TextEditingController();
    String? selectedCategory;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nueva Meta', style: AppTextStyles.heading2),
                const SizedBox(height: 20),
                AppInput(hint: 'Ej: Meditar 20 min diarios', label: 'Describe tu meta', controller: titleCtrl),
                const SizedBox(height: 16),
                const Text('Categoría', style: AppTextStyles.body),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: ['Bienestar', 'Ejercicio', 'Finanzas', 'Estudio', 'Relaciones'].map((c) =>
                    GestureDetector(
                      onTap: () => setModal(() => selectedCategory = c),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: selectedCategory == c ? AppColors.primary : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(c, style: TextStyle(color: selectedCategory == c ? Colors.white : AppColors.textSecondary, fontSize: 13)),
                      ),
                    )
                  ).toList(),
                ),
                const SizedBox(height: 20),
                AppButton(
                  label: 'Crear meta',
                  width: double.infinity,
                  onPressed: () {
                    // TODO: POST /goals con { title, category, userId }
                    Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        title: const Text('Mis Metas'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateGoal,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Nueva meta', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Consejo IA adaptado al ciclo
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppDecorations.gradientCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(children: [
                    Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 18),
                    SizedBox(width: 8),
                    Text('Consejo adaptado a tu ciclo', style: AppTextStyles.heading3),
                  ]),
                  const SizedBox(height: 10),
                  // TODO: Obtener de POST /goals/advice con fase del ciclo
                  const Text('En tu fase lútea actual, es mejor mantener metas que ya empezaste. Evita iniciar algo completamente nuevo y enfócate en consolidar los progresos existentes. 🌙', style: AppTextStyles.bodySecondary),
                  const SizedBox(height: 10),
                  AppButton(label: 'Nuevo consejo IA', style: AppButtonStyle.ghost, onPressed: () {}),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SectionTitle(title: 'Metas activas'),
            const SizedBox(height: 12),
            ..._goals.map((g) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _buildGoalCard(g))),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(_Goal goal) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(goal.title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600))),
              AppBadge(label: goal.category, type: BadgeType.custom, customColor: goal.color),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(goal.progress * 100).round()}%', style: AppTextStyles.body.copyWith(color: goal.color, fontWeight: FontWeight.bold)),
              Text('Meta en progreso', style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: goal.progress,
            backgroundColor: goal.color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation(goal.color),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

class _Goal {
  final String title, category;
  final double progress;
  final Color color;
  _Goal(this.title, this.category, this.progress, this.color);
}
