// ════════════════════════════════════════════════════════════
//  DEV 1 — DIARIO EMOCIONAL (MODO LOCAL)
// ════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../services/api_service.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});
  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen>
    with SingleTickerProviderStateMixin {
  static const _kDefaultMood = '😐';
  static const _kMoods = ['😢', '😔', '😐', '🙂', '😊', '🤩'];
  static const _kMonths = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];

  final Map<String, String> _moodQuestions = {
    '😢': 'Siento que hoy ha sido un día difícil... ¿Qué es lo que más te hace sentir así? 💜',
    '😔': 'Parece que algo te preocupa... ¿Quieres desahogarte y contarme qué tienes en mente? 🌸',
    '😐': 'Un día tranquilo... ¿Qué ha sido lo más relevante de tu jornada hoy? ✨',
    '🙂': '¡Me alegra que estés bien! ¿Hubo algo especial que te hizo sonreír hoy? 😊',
    '😊': '¡Qué bonita energía! Cuéntame, ¿qué te hace sentir tan plena hoy? 🌟',
    '🤩': '¡Increíble! Esa emoción es contagiosa. ¡Cuéntame qué te hace brillar hoy! 💖',
  };

  final Map<String, List<String>> _localResponses = {
    '😢': [
      'Lamento mucho que te sientas así. Recuerda que está bien no estar bien. Estoy aquí para escucharte. 💜',
      'Mañana será un nuevo comienzo. Por ahora, intenta descansar y ser amable contigo misma. 🌸'
    ],
    '😔': [
      'Gracias por confiarme esto. A veces soltar lo que nos pesa es el primer paso para sanar. ✨',
      'Eres muy valiente al expresar lo que sientes. No estás sola en esto. 💜'
    ],
    '😐': [
      'Entiendo. A veces los días simplemente fluyen. Lo importante es que te has tomado un momento para ti. 🌿',
      'Gracias por registrar tu día. Mañana seguiremos adelante. ✨'
    ],
    '🙂': [
      '¡Me alegra leer esto! Qué bueno que hayas tenido un momento positivo hoy. 😊',
      '¡Sigue así! Cultivar esos pequeños momentos de bienestar hace la diferencia. 🌟'
    ],
    '😊': [
      '¡Qué alegría! Tu bienestar es prioridad. Me encanta que compartas tu felicidad conmigo. 💖',
      '¡Excelente día! Guarda este sentimiento para cuando necesites un extra de energía. 🤩'
    ],
    '🤩': [
      '¡Increíble! Esa energía es maravillosa. ¡Me hace muy feliz que estés brillando así hoy! 🌟✨',
      '¡Brillante! Disfruta al máximo este momento, te lo mereces. 💜'
    ],
  };

  late TabController _tabCtrl;
  final _entryCtrl = TextEditingController();
  bool _loadingSubmit = false;
  bool _loadingHistory = false;
  String? _aiResponse;
  String _selectedMood = _kDefaultMood;

  // Usamos una lista estática para que los datos persistan durante la sesión
  static final List<_DiaryEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  // ── Simulación de carga de historial ──────────────────
  Future<void> _loadHistory() async {
    // Ya no llamamos al backend
    setState(() => _loadingHistory = false);
  }

  // ── Guardado local y respuesta personalizada ──────────
  Future<void> _submitEntry() async {
    final text = _entryCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _loadingSubmit = true;
      _aiResponse = null;
    });

    // Simulamos un pequeño retraso para que parezca que la IA "piensa"
    await Future.delayed(const Duration(seconds: 1));

    // Obtener respuesta personalizada
    final responses = _localResponses[_selectedMood] ?? ['Gracias por compartir esto conmigo. 💜'];
    final aiResp = (responses..shuffle()).first;

    final newEntry = _DiaryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      mood: _selectedMood,
      date: DateTime.now(),
      aiResponse: aiResp,
    );

    if (mounted) {
      setState(() {
        _aiResponse = aiResp;
        _entries.insert(0, newEntry); 
        _loadingSubmit = false;
      });
      _entryCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context)),
        title: const Text('Diario Emocional'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: AppColors.primary),
            onPressed: () => _tabCtrl.animateTo(1),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textLight,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Escribir'),
            Tab(text: 'Historial'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildWriteTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildWriteTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('¿Cómo te sientes ahora?',
                    style: AppTextStyles.heading3),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _kMoods.map((e) {
                    final selected = _selectedMood == e;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedMood = e),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary.withOpacity(0.15)
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Center(
                            child: Text(e,
                                style: TextStyle(
                                    fontSize: selected ? 26 : 22))),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.edit_note_rounded,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  const Text('Cuéntame sobre tu día',
                      style: AppTextStyles.heading3),
                ]),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _entryCtrl,
                  maxLines: 8,
                  decoration: InputDecoration(
                    hintText: _moodQuestions[_selectedMood] ??
                        'Escribe libremente... Este es tu espacio seguro 🌸',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                  ),
                  style: AppTextStyles.body.copyWith(height: 1.6),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_loadingSubmit)
            AppCard(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  const CircularProgressIndicator(
                      color: AppColors.primary, strokeWidth: 2.5),
                  const SizedBox(height: 12),
                  Text('Alma está leyendo tu entrada...',
                      style: AppTextStyles.bodySecondary),
                  const SizedBox(height: 8),
                ],
              ),
            )
          else if (_aiResponse != null)
            _buildAIResponse(_aiResponse!),
          const SizedBox(height: 20),
          AppButton(
            label: _loadingSubmit ? 'Enviando...' : 'Enviar al diario 💜',
            isLoading: _loadingSubmit,
            onPressed: _loadingSubmit ? null : _submitEntry,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildAIResponse(String response) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.primaryLight.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset('assets/images/logo.png', width: 36, height: 36),
              const SizedBox(width: 10),
              const Text('Respuesta de Alma',
                  style: AppTextStyles.heading3),
            ],
          ),
          const SizedBox(height: 12),
          Text(response,
              style: AppTextStyles.body.copyWith(height: 1.7)),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('📖', style: TextStyle(fontSize: 52)),
              const SizedBox(height: 16),
              const Text('Tu diario está vacío',
                  style: AppTextStyles.heading3),
              const SizedBox(height: 8),
              Text('Escribe tu primera entrada en la pestaña "Escribir"',
                  style: AppTextStyles.bodySecondary,
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _buildEntryCard(_entries[i]),
    );
  }

  Widget _buildEntryCard(_DiaryEntry entry) {
    return AppCard(
      onTap: () => _showEntryDetail(entry),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(entry.mood, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_formatDate(entry.date), style: AppTextStyles.caption),
                const Text('Entrada del diario',
                    style: AppTextStyles.bodySecondary),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textLight),
          ]),
          const SizedBox(height: 10),
          Text(entry.text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(height: 1.5)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10)),
            child: Text('💜 ${entry.aiResponse}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption),
          ),
        ],
      ),
    );
  }

  void _showEntryDetail(_DiaryEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        builder: (_, ctrl) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: ctrl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: AppColors.textLight,
                            borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                Row(children: [
                  Text(entry.mood,
                      style: const TextStyle(fontSize: 36)),
                  const SizedBox(width: 12),
                  Text(_formatDate(entry.date),
                      style: AppTextStyles.bodySecondary),
                ]),
                const SizedBox(height: 16),
                Text(entry.text,
                    style: AppTextStyles.body.copyWith(height: 1.7)),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: AppDecorations.gradientCard,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Image.asset('assets/images/logo.png',
                            width: 28, height: 28),
                        const SizedBox(width: 8),
                        const Text('💜 Respuesta de Alma',
                            style: AppTextStyles.heading3),
                      ]),
                      const SizedBox(height: 8),
                      Text(entry.aiResponse,
                          style:
                              AppTextStyles.body.copyWith(height: 1.7)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day} ${_kMonths[d.month - 1]} ${d.year}';
}

class _DiaryEntry {
  final String id;
  final String text;
  final String mood;
  final DateTime date;
  final String aiResponse;

  _DiaryEntry({
    required this.id,
    required this.text,
    required this.mood,
    required this.date,
    required this.aiResponse,
  });

  factory _DiaryEntry.fromJson(Map<String, dynamic> json) => _DiaryEntry(
        id: json['id']?.toString() ?? '',
        text: json['text']?.toString() ?? '',
        mood: json['mood']?.toString() ?? '😐',
        date: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
            DateTime.now(),
        aiResponse: json['ai_response']?.toString() ?? '',
      );
}
