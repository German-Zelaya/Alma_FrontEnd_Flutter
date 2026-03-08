// ════════════════════════════════════════════════════════════
//  DEV 3 — AGENDA VIVA & INDEPENDENCIA/CRECIMIENTO
// ════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

// ─── AGENDA VIVA ─────────────────────────────────────────
// GET /tasks · POST /tasks · DELETE /tasks/:id
// Consume GET /cycle/current para el tip del día
class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});
  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  BadgeType _filter = BadgeType.status; // 'all' represented as status
  final _newTaskCtrl = TextEditingController();

  // TODO: Obtener de GET /tasks
  List<_Task> _tasks = [
    _Task('Sesión de meditación matutina', BadgeType.high, false),
    _Task('Revisar metas de la semana', BadgeType.medium, false),
    _Task('Llamar a mamá', BadgeType.low, true),
    _Task('Preparar presentación del trabajo', BadgeType.high, false),
    _Task('Hacer ejercicio 30 minutos', BadgeType.medium, false),
  ];

  List<_Task> get _filteredTasks {
    if (_filter == BadgeType.status) return _tasks;
    return _tasks.where((t) => t.priority == _filter).toList();
  }

  void _toggleTask(int i) {
    final actual = _filteredTasks[i];
    final realIdx = _tasks.indexOf(actual);
    setState(() => _tasks[realIdx] = _Task(actual.title, actual.priority, !actual.completed));
    // TODO: PATCH /tasks/:id con { completed: !task.completed }
  }

  void _deleteTask(_Task task) {
    setState(() => _tasks.remove(task));
    // TODO: DELETE /tasks/:id
  }

  void _showAddTask() {
    BadgeType selectedPriority = BadgeType.medium;
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
                const Text('Crear tarea', style: AppTextStyles.heading2),
                const SizedBox(height: 16),
                AppInput(hint: 'Ej: Meditar 20 minutos', label: 'Tarea', controller: _newTaskCtrl),
                const SizedBox(height: 16),
                const Text('Prioridad', style: AppTextStyles.body),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _PriorityChip('Alta', BadgeType.high, selectedPriority, (p) => setModal(() => selectedPriority = p)),
                    const SizedBox(width: 8),
                    _PriorityChip('Media', BadgeType.medium, selectedPriority, (p) => setModal(() => selectedPriority = p)),
                    const SizedBox(width: 8),
                    _PriorityChip('Baja', BadgeType.low, selectedPriority, (p) => setModal(() => selectedPriority = p)),
                  ],
                ),
                const SizedBox(height: 20),
                AppButton(
                  label: 'Crear tarea',
                  width: double.infinity,
                  onPressed: () {
                    if (_newTaskCtrl.text.trim().isNotEmpty) {
                      setState(() => _tasks.insert(0, _Task(_newTaskCtrl.text.trim(), selectedPriority, false)));
                      _newTaskCtrl.clear();
                      // TODO: POST /tasks con { title, priority, date: today }
                      Navigator.pop(ctx);
                    }
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
    final completed = _tasks.where((t) => t.completed).length;
    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        title: const Text('Agenda Viva'),
        actions: [
          IconButton(icon: const Icon(Icons.calendar_month_rounded, color: AppColors.primary), onPressed: () {}),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTask,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tip del día (GET /cycle/current)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tip según tu ciclo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        SizedBox(height: 4),
                        Text('Fase Lútea: Prioriza tareas de enfoque profundo y evita multitasking.', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Resumen
            Row(
              children: [
                Expanded(child: AppInfoCard(label: 'Total', value: '${_tasks.length}', icon: const Icon(Icons.list_rounded, color: AppColors.primary, size: 18))),
                const SizedBox(width: 10),
                Expanded(child: AppInfoCard(label: 'Completadas', value: '$completed', color: AppColors.badgeLow, icon: const Icon(Icons.check_circle_rounded, color: AppColors.badgeLow, size: 18))),
                const SizedBox(width: 10),
                Expanded(child: AppInfoCard(label: 'Pendientes', value: '${_tasks.length - completed}', color: AppColors.badgeHigh, icon: const Icon(Icons.pending_rounded, color: AppColors.badgeHigh, size: 18))),
              ],
            ),
            const SizedBox(height: 20),

            // Filtros
            const Text('Tareas del día', style: AppTextStyles.heading3),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip('Todas', BadgeType.status, _filter, (f) => setState(() => _filter = f)),
                  const SizedBox(width: 8),
                  _FilterChip('Alta', BadgeType.high, _filter, (f) => setState(() => _filter = f)),
                  const SizedBox(width: 8),
                  _FilterChip('Media', BadgeType.medium, _filter, (f) => setState(() => _filter = f)),
                  const SizedBox(width: 8),
                  _FilterChip('Baja', BadgeType.low, _filter, (f) => setState(() => _filter = f)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Lista tareas
            ..._filteredTasks.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TaskItem(
                title: e.value.title,
                priority: e.value.priority,
                completed: e.value.completed,
                onToggle: () => _toggleTask(e.key),
                onDelete: () => _deleteTask(e.value),
              ),
            )),

            if (_filteredTasks.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      const Text('🎉', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      Text('¡Todo completado!', style: AppTextStyles.heading3.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Task {
  final String title;
  final BadgeType priority;
  final bool completed;
  _Task(this.title, this.priority, this.completed);
}

class _FilterChip extends StatelessWidget {
  final String label;
  final BadgeType type;
  final BadgeType selected;
  final ValueChanged<BadgeType> onSelect;
  const _FilterChip(this.label, this.type, this.selected, this.onSelect);

  Color get _color {
    switch (type) {
      case BadgeType.high: return AppColors.badgeHigh;
      case BadgeType.medium: return AppColors.badgeMedium;
      case BadgeType.low: return AppColors.badgeLow;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == type;
    return GestureDetector(
      onTap: () => onSelect(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? _color : AppColors.primaryLight.withOpacity(0.4)),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, fontSize: 13)),
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final String label;
  final BadgeType type;
  final BadgeType selected;
  final ValueChanged<BadgeType> onSelect;
  const _PriorityChip(this.label, this.type, this.selected, this.onSelect);

  Color get _color {
    switch (type) {
      case BadgeType.high: return AppColors.badgeHigh;
      case BadgeType.medium: return AppColors.badgeMedium;
      case BadgeType.low: return AppColors.badgeLow;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == type;
    return GestureDetector(
      onTap: () => onSelect(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _color.withOpacity(0.15) : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? _color : Colors.transparent),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? _color : AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }
}

// ─── INDEPENDENCIA & CRECIMIENTO ─────────────────────────
// GET /growth/tip · Lambda + Bedrock para recursos personalizados
// DynamoDB: guardar recursos favoritos · S3: archivos multimedia
class GrowthScreen extends StatefulWidget {
  const GrowthScreen({super.key});
  @override
  State<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends State<GrowthScreen> {
  String? _selectedCategory;

  final _categories = [
    _GrowthCategory('Finanzas', Icons.attach_money_rounded, AppColors.badgeMedium),
    _GrowthCategory('Emprendimiento', Icons.rocket_launch_rounded, AppColors.primary),
    _GrowthCategory('Habilidades', Icons.psychology_rounded, Color(0xFF3B82F6)),
    _GrowthCategory('Autocuidado', Icons.spa_rounded, AppColors.badgeLow),
  ];

  // TODO: Cargar de DynamoDB (recursos favoritos del usuario)
  final _favorites = [
    _Resource('Artículos de finanzas personales para mujeres', 'Finanzas', '5 min', true),
    _Resource('Meditación guiada para el estrés laboral', 'Autocuidado', '10 min', true),
    _Resource('Cómo negociar tu salario con confianza', 'Emprendimiento', '8 min', false),
  ];

  // TODO: Cargar de GET /growth/tip (Bedrock personalizado)
  final String _dailyTip = 'Basado en tu perfil y fase lútea actual, te recomendamos enfocarte en actividades de reflexión financiera. Haz un balance de tus gastos del mes. 💜';

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        title: const Text('Independencia & Crecimiento'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDailyTip(),
            const SizedBox(height: 20),
            _buildCategories(),
            const SizedBox(height: 20),
            _buildAchievements(),
            const SizedBox(height: 20),
            _buildFavorites(),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyTip() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppDecorations.primaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Text('✨', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text('Recurso personalizado del día', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          ]),
          const SizedBox(height: 10),
          Text(_dailyTip, style: const TextStyle(color: Colors.white70, height: 1.6, fontSize: 13)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              // TODO: POST /growth/generate-resource
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
              child: const Text('Generar recurso personalizado', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Categorías'),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: _categories.map((c) => _CategoryCard(category: c, onTap: () {
            setState(() => _selectedCategory = _selectedCategory == c.name ? null : c.name);
          })).toList(),
        ),
      ],
    );
  }

  Widget _buildAchievements() {
    final milestones = [
      ('🌱', '7 días consecutivos', 'Racha de hábitos'),
      ('⭐', '50 entradas', 'Diario emocional'),
      ('🏆', '5 metas cumplidas', 'Superadora'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Tus logros'),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: milestones.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final m = milestones[i];
              return Container(
                width: 140,
                padding: const EdgeInsets.all(14),
                decoration: AppDecorations.gradientCard,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m.$1, style: const TextStyle(fontSize: 24)),
                    const SizedBox(height: 4),
                    Text(m.$2, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, fontSize: 12)),
                    Text(m.$3, style: AppTextStyles.caption),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFavorites() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Tus recursos favoritos'),
        const SizedBox(height: 12),
        ..._favorites.map((r) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppCard(
            onTap: () {},
            child: Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.article_rounded, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(children: [
                        AppBadge(label: r.category, type: BadgeType.status),
                        const SizedBox(width: 8),
                        Text('· ${r.duration}', style: AppTextStyles.caption),
                      ]),
                    ],
                  ),
                ),
                Icon(r.favorited ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, color: r.favorited ? AppColors.primary : AppColors.textLight),
              ],
            ),
          ),
        )),
      ],
    );
  }
}

class _GrowthCategory {
  final String name;
  final IconData icon;
  final Color color;
  _GrowthCategory(this.name, this.icon, this.color);
}

class _Resource {
  final String title, category, duration;
  final bool favorited;
  _Resource(this.title, this.category, this.duration, this.favorited);
}

class _CategoryCard extends StatelessWidget {
  final _GrowthCategory category;
  final VoidCallback onTap;
  const _CategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: category.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: category.color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(category.icon, color: category.color, size: 28),
            const SizedBox(height: 8),
            Text(category.name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, color: category.color)),
          ],
        ),
      ),
    );
  }
}
