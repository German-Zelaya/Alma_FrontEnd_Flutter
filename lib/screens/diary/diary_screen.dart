// ════════════════════════════════════════════════════════════
//  DEV 1 — DIARIO EMOCIONAL
//  POST /journal → nueva entrada + respuesta IA (Bedrock)
//  GET  /journal → historial de entradas
// ════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});
  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _entryCtrl = TextEditingController();
  bool _loading = false;
  String? _aiResponse;

  // TODO: Obtener de GET /journal
  final List<_DiaryEntry> _entries = [
    _DiaryEntry('Hoy me sentí muy productiva y agradecida por las pequeñas cosas.', '😊', DateTime.now().subtract(const Duration(days: 1)), 'Qué hermoso que puedas notar esas pequeñas alegrías...'),
    _DiaryEntry('Tuve un día difícil, me sentí abrumada con el trabajo.', '😔', DateTime.now().subtract(const Duration(days: 2)), 'Es completamente válido sentirse así. Recuerda...'),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  Future<void> _submitEntry() async {
    if (_entryCtrl.text.trim().isEmpty) return;
    setState(() { _loading = true; _aiResponse = null; });

    // TODO: Llamar POST /journal con el texto
    // final response = await apiCall('/journal', 'POST', { 'text': _entryCtrl.text });
    // _aiResponse = response['ai_response'];
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _aiResponse = 'Gracias por compartir esto conmigo 💜. Lo que describes muestra mucha valentía y autoconciencia. Recuerda que cada sentimiento tiene su valor y es parte de tu camino.';
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        title: const Text('Diario Emocional'),
        actions: [
          IconButton(icon: const Icon(Icons.history_rounded, color: AppColors.primary), onPressed: () => _tabCtrl.animateTo(1)),
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
          // Mood selector
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('¿Cómo te sientes ahora?', style: AppTextStyles.heading3),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['😢', '😔', '😐', '🙂', '😊', '🤩'].map((e) =>
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 46, height: 46,
                        decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(12)),
                        child: Center(child: Text(e, style: const TextStyle(fontSize: 24))),
                      ),
                    )
                  ).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Texto libre
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    const Text('Cuéntame sobre tu día', style: AppTextStyles.heading3),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _entryCtrl,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    hintText: 'Escribe libremente... Este es tu espacio seguro 🌸',
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

          // Respuesta de IA
          if (_loading)
            AppCard(
              child: Column(
                children: [
                  const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
                  const SizedBox(height: 12),
                  Text('Procesando tu entrada...', style: AppTextStyles.bodySecondary),
                ],
              ),
            )
          else if (_aiResponse != null)
            _buildAIResponse(_aiResponse!),

          const SizedBox(height: 20),
          AppButton(
            label: _loading ? 'Enviando...' : 'Enviar al diario 💜',
            isLoading: _loading,
            onPressed: _submitEntry,
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
        border: Border.all(color: AppColors.primaryLight.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: AppDecorations.primaryContainer,
                child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              const Text('Respuesta empática', style: AppTextStyles.heading3),
            ],
          ),
          const SizedBox(height: 12),
          Text(response, style: AppTextStyles.body.copyWith(height: 1.7)),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    // TODO: Cargar de GET /journal
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
          Row(
            children: [
              Text(entry.mood, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_formatDate(entry.date), style: AppTextStyles.caption),
                  const Text('Entrada del diario', style: AppTextStyles.bodySecondary),
                ],
              ),
              const Spacer(),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
            ],
          ),
          const SizedBox(height: 10),
          Text(entry.text, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.body.copyWith(height: 1.5)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(10)),
            child: Text('💜 ${entry.aiResponse}', maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.caption),
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: ctrl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textLight, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                Row(children: [
                  Text(entry.mood, style: const TextStyle(fontSize: 36)),
                  const SizedBox(width: 12),
                  Text(_formatDate(entry.date), style: AppTextStyles.bodySecondary),
                ]),
                const SizedBox(height: 16),
                Text(entry.text, style: AppTextStyles.body.copyWith(height: 1.7)),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: AppDecorations.gradientCard,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('💜 Respuesta de Florece', style: AppTextStyles.heading3),
                      const SizedBox(height: 8),
                      Text(entry.aiResponse, style: AppTextStyles.body.copyWith(height: 1.7)),
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

  String _formatDate(DateTime d) {
    return '${d.day}/${d.month}/${d.year}';
  }
}

class _DiaryEntry {
  final String text;
  final String mood;
  final DateTime date;
  final String aiResponse;
  _DiaryEntry(this.text, this.mood, this.date, this.aiResponse);
}
