// ════════════════════════════════════════════════════════════
//  DEV 4 — MODO COMPAÑÍA, SOPORTE EMOCIONAL IA, NOTIFICACIONES
// ════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../services/api_service.dart';

// ─── MODELO DE CONTACTO ───────────────────────────────────
class _Contact {
  final String id;
  final String name;
  final String phone;
  _Contact({required this.id, required this.name, required this.phone});

  factory _Contact.fromJson(Map<String, dynamic> json) => _Contact(
        id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
      );
}

// ─── MODO COMPAÑÍA ────────────────────────────────────────
// POST /safety/activate · GET/POST/DELETE /safety/contacts
class CompanionScreen extends StatefulWidget {
  const CompanionScreen({super.key});
  @override
  State<CompanionScreen> createState() => _CompanionScreenState();
}

class _CompanionScreenState extends State<CompanionScreen>
    with SingleTickerProviderStateMixin {
  bool _companionActive = false;
  bool _loadingContacts = true;
  bool _activating = false;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  final List<_Contact> _contacts = [];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.12).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _loadContacts();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Cargar contactos desde la API ─────────────────────
  Future<void> _loadContacts() async {
    setState(() => _loadingContacts = true);
    try {
      final userId = await ApiService.getUserId() ?? 'default_user';
      final list = await SafetyService.getContacts(userId);
      if (mounted) {
        setState(() {
          _contacts.clear();
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              _contacts.add(_Contact.fromJson(item));
            }
          }
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        _showError('No se pudieron cargar los contactos: ${e.message}');
      }
    } finally {
      if (mounted) setState(() => _loadingContacts = false);
    }
  }

  // ── Activar / Desactivar Modo Compañía ────────────────
  Future<void> _toggleCompanion() async {
    if (_activating) return;

    if (!_companionActive) {
      // Activar: llamar a la API
      setState(() => _activating = true);
      try {
        final userId = await ApiService.getUserId() ?? 'default_user';
        // TODO: integrar geolocator para obtener coordenadas GPS reales
        // Por ahora se envían coordenadas neutras; agregar geolocator al pubspec
        // y reemplazar con: final pos = await Geolocator.getCurrentPosition();
        await SafetyService.activateCompanion(
          userId: userId,
          userName: 'Usuario Florece',
          lat: 0.0,
          lng: 0.0,
        );
        setState(() => _companionActive = true);
        _showActivationFeedback();
      } on ApiException catch (e) {
        _showError('Error al activar: ${e.message}');
      } finally {
        if (mounted) setState(() => _activating = false);
      }
    } else {
      // Desactivar localmente
      setState(() => _companionActive = false);
    }
  }

  void _showActivationFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
            'Modo Compañía activado. Tus contactos han sido notificados. 💜'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.badgeHigh,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Modal para agregar contacto ───────────────────────
  void _showAddContact() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(24))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Agregar contacto de confianza',
                    style: AppTextStyles.heading2),
                const SizedBox(height: 20),
                AppInput(
                  hint: 'Nombre del contacto',
                  label: 'Nombre',
                  controller: nameCtrl,
                  prefixIcon: const Icon(Icons.person_outline_rounded,
                      color: AppColors.primaryLight),
                ),
                const SizedBox(height: 16),
                AppInput(
                  hint: '+591 7XXXXXXX',
                  label: 'Teléfono',
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined,
                      color: AppColors.primaryLight),
                ),
                const SizedBox(height: 20),
                AppButton(
                  label: saving ? 'Guardando...' : 'Agregar contacto',
                  width: double.infinity,
                  onPressed: saving
                      ? null
                      : () async {
                          if (nameCtrl.text.isEmpty ||
                              phoneCtrl.text.isEmpty) return;
                          setModalState(() => saving = true);
                          try {
                            final userId =
                                await ApiService.getUserId() ?? 'default_user';
                            final result = await SafetyService.addContact(
                              userId,
                              nameCtrl.text.trim(),
                              phoneCtrl.text.trim(),
                            );
                            // El backend devuelve el contacto creado con su id
                            final newContact = _Contact(
                              id: result['id']?.toString() ??
                                  result['_id']?.toString() ??
                                  DateTime.now().millisecondsSinceEpoch.toString(),
                              name: nameCtrl.text.trim(),
                              phone: phoneCtrl.text.trim(),
                            );
                            if (mounted) {
                              setState(() => _contacts.add(newContact));
                              Navigator.pop(ctx);
                            }
                          } on ApiException catch (e) {
                            setModalState(() => saving = false);
                            _showError('Error al agregar: ${e.message}');
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

  // ── Eliminar contacto ─────────────────────────────────
  Future<void> _deleteContact(_Contact contact) async {
    if (contact.id.isEmpty) {
      setState(() => _contacts.remove(contact));
      return;
    }
    try {
      final userId = await ApiService.getUserId() ?? 'default_user';
      await SafetyService.deleteContact(contact.id, userId);
      if (mounted) setState(() => _contacts.remove(contact));
    } on ApiException catch (e) {
      _showError('Error al eliminar: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context)),
        title: const Text('Modo Compañía'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadContacts,
            tooltip: 'Recargar contactos',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Botón de activación principal
            _buildActivationButton(),
            const SizedBox(height: 24),

            // Instrucciones
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(children: [
                    Icon(Icons.info_outline_rounded,
                        color: AppColors.primary, size: 18),
                    SizedBox(width: 8),
                    Text('¿Cómo funciona?', style: AppTextStyles.heading3),
                  ]),
                  const SizedBox(height: 12),
                  _InfoStep('1',
                      'Activa el Modo Compañía con el botón grande de arriba'),
                  _InfoStep(
                      '2', 'Se enviará un SMS automático a tus contactos de confianza'),
                  _InfoStep(
                      '3', 'Ellos sabrán que necesitas apoyo o compañía'),
                  _InfoStep('4', 'Cuando estés segura, desactiva el modo'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Contactos de confianza
            SectionTitle(
              title: 'Contactos de confianza',
              action: '+ Agregar',
              onAction: _showAddContact,
            ),
            const SizedBox(height: 12),

            if (_loadingContacts)
              const Center(
                  child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: AppColors.primary),
              ))
            else if (_contacts.isEmpty)
              AppCard(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Aún no tienes contactos de confianza.\nToca "+ Agregar" para añadir uno.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySecondary,
                    ),
                  ),
                ),
              )
            else
              ..._contacts.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCard(
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle),
                            child: const Icon(Icons.person_rounded,
                                color: AppColors.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.name,
                                  style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w600)),
                              Text(c.phone, style: AppTextStyles.caption),
                            ],
                          )),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded,
                                color: AppColors.textLight, size: 20),
                            onPressed: () => _deleteContact(c),
                          ),
                        ],
                      ),
                    ),
                  )),

            const SizedBox(height: 20),

            // Líneas de ayuda
            const SectionTitle(title: 'Líneas de ayuda'),
            const SizedBox(height: 12),
            _buildHelpLine('Bolivia', '800-10-0200', 'Línea de violencia'),
            _buildHelpLine('Bolivia', '110', 'Policía Nacional'),
            _buildHelpLine('Internacional', '116', 'Cruz Roja'),
          ],
        ),
      ),
    );
  }

  Widget _buildActivationButton() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulse,
          builder: (_, child) => Transform.scale(
            scale: _companionActive ? _pulse.value : 1.0,
            child: GestureDetector(
              onTap: _toggleCompanion,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  gradient: _companionActive
                      ? const LinearGradient(
                          colors: [Color(0xFFEF4444), Color(0xFFDC2626)])
                      : AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_companionActive ? Colors.red : AppColors.primary)
                          .withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: _activating
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white))
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                              _companionActive
                                  ? Icons.shield_rounded
                                  : Icons.shield_outlined,
                              color: Colors.white,
                              size: 48),
                          const SizedBox(height: 8),
                          Text(
                            _companionActive ? 'ACTIVO' : 'ACTIVAR',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 1.5),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _companionActive
              ? '🔴 Modo Compañía activado\nTus contactos han sido notificados'
              : 'Presiona para activar el Modo Compañía',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySecondary
              .copyWith(color: _companionActive ? Colors.red : null),
        ),
      ],
    );
  }

  Widget _buildHelpLine(String country, String number, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.badgeHigh.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.badgeHigh.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.phone_rounded,
                color: AppColors.badgeHigh, size: 20),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(desc,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w600)),
                Text('$country · $number', style: AppTextStyles.caption),
              ],
            )),
            Text(number,
                style: AppTextStyles.body.copyWith(
                    color: AppColors.badgeHigh, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _InfoStep extends StatelessWidget {
  final String step, text;
  const _InfoStep(this.step, this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration:
                BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: Center(
                child: Text(step,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Text(text, style: AppTextStyles.bodySecondary)),
        ],
      ),
    );
  }
}

// ─── SOPORTE EMOCIONAL IA ─────────────────────────────────
// POST /support/chat → Bedrock con detección de crisis
class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});
  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _isTyping = false;
  bool _showCrisisBanner = true; // siempre visible por seguridad
  bool _isCrisis = false;
  String? _userId;

  final List<_ChatMsg> _messages = [
    _ChatMsg(
        'Hola 💜 Estoy aquí para escucharte. ¿Cómo te sientes en este momento?',
        false),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    _userId = await ApiService.getUserId() ?? 'default_user';
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _isTyping) return;

    setState(() {
      _messages.add(_ChatMsg(text, true));
      _isTyping = true;
    });
    _msgCtrl.clear();
    _scrollToBottom();

    try {
      final userId = _userId ?? 'default_user';
      final result = await SupportService.sendMessage(text, userId);

      final response = result['response']?.toString() ??
          'Lo siento, no pude procesar tu mensaje. Intenta de nuevo. 💜';
      final isCrisis = result['isCrisis'] == true;

      if (mounted) {
        setState(() {
          _isTyping = false;
          _isCrisis = isCrisis;
          _showCrisisBanner = true; // mantener visible siempre
          _messages.add(_ChatMsg(response, false));
        });
        _scrollToBottom();
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(_ChatMsg(
              'Tuve un problema al conectarme (${e.message}). '
              'Por favor intenta de nuevo. Estoy aquí para ti. 💜',
              false));
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context)),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: AppDecorations.primaryContainer,
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Florece IA', style: AppTextStyles.body),
                Text('Soporte emocional',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.badgeLow)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shield_outlined, color: AppColors.badgeHigh),
            onPressed: () => Navigator.pushNamed(context, '/companion'),
            tooltip: 'Modo Compañía',
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner de crisis — siempre visible, más prominente si isCrisis
          if (_showCrisisBanner) _buildCrisisBanner(),

          // Mensajes
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (_, i) {
                if (_isTyping && i == _messages.length) {
                  return _buildTypingIndicator();
                }
                return _buildMessage(_messages[i]);
              },
            ),
          ),

          // Sugerencias rápidas (solo al inicio)
          if (_messages.length == 1) _buildQuickSuggestions(),

          // Input
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildCrisisBanner() {
    final color = _isCrisis ? AppColors.badgeHigh : AppColors.badgeHigh;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: color.withOpacity(_isCrisis ? 0.18 : 0.08),
      child: Row(
        children: [
          Icon(Icons.favorite_rounded, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
              child: Text(
            'Si estás en crisis, también puedes llamar al 800-10-0200',
            style: TextStyle(fontSize: 12, color: color),
          )),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/companion'),
            child: Text('Activar compañía',
                style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(_ChatMsg msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: msg.isUser ? AppColors.primaryGradient : null,
          color: msg.isUser ? null : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(msg.isUser ? 18 : 4),
            bottomRight: Radius.circular(msg.isUser ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
                color: AppColors.primary.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Text(msg.text,
            style: AppTextStyles.body.copyWith(
                color: msg.isUser ? Colors.white : AppColors.textPrimary,
                height: 1.5)),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(delay: 0),
            const SizedBox(width: 4),
            _Dot(delay: 200),
            const SizedBox(width: 4),
            _Dot(delay: 400),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSuggestions() {
    final suggestions = [
      'Me siento ansiosa',
      'Tuve un mal día',
      'Necesito hablar',
      'Me siento triste'
    ];
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: suggestions
            .map((s) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      _msgCtrl.text = s;
                      _sendMessage();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.primaryLight.withOpacity(0.4)),
                      ),
                      child: Text(s,
                          style: AppTextStyles.bodySecondary
                              .copyWith(color: AppColors.primary)),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _msgCtrl,
                maxLines: 4,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Cuéntame cómo te sientes...',
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 46,
                height: 46,
                decoration: AppDecorations.primaryContainer,
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});
  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _anim,
        child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
                color: AppColors.primary, shape: BoxShape.circle)),
      );
}

class _ChatMsg {
  final String text;
  final bool isUser;
  _ChatMsg(this.text, this.isUser);
}

// ─── AJUSTES / NOTIFICACIONES ─────────────────────────────
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _dailyReminder = true;
  bool _weeklyReport = true;
  bool _cycleAlerts = true;
  bool _habitReminders = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context)),
        title: const Text('Configuración'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Perfil
            AppCard(
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: AppDecorations.primaryContainer,
                    child: const Icon(Icons.person_rounded,
                        color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sofía García', style: AppTextStyles.heading3),
                      Text('sofia@email.com', style: AppTextStyles.caption),
                    ],
                  )),
                  AppBadge(
                      label: 'Pro',
                      type: BadgeType.custom,
                      customColor: AppColors.badgeMedium),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text('Notificaciones', style: AppTextStyles.heading3),
            const SizedBox(height: 12),
            _buildSwitch(
                'Recordatorio diario',
                'A las ${_reminderTime.format(context)}',
                Icons.notifications_rounded,
                _dailyReminder,
                (v) => setState(() => _dailyReminder = v)),
            const SizedBox(height: 10),
            _buildSwitch(
                'Resumen semanal (lunes)',
                'Recibe tu informe cada semana',
                Icons.calendar_today_rounded,
                _weeklyReport,
                (v) => setState(() => _weeklyReport = v)),
            const SizedBox(height: 10),
            _buildSwitch(
                'Alertas de fase del ciclo',
                'Notificaciones sobre tu ciclo',
                Icons.favorite_rounded,
                _cycleAlerts,
                (v) => setState(() => _cycleAlerts = v)),
            const SizedBox(height: 10),
            _buildSwitch(
                'Recordatorio de hábitos',
                'Recordatorio para registrar tus hábitos',
                Icons.check_box_outlined,
                _habitReminders,
                (v) => setState(() => _habitReminders = v)),
            const SizedBox(height: 24),

            const Text('Seguridad y privacidad', style: AppTextStyles.heading3),
            const SizedBox(height: 12),
            _buildTile(
                'Modo Compañía',
                'Gestionar contactos de confianza',
                Icons.shield_rounded,
                () => Navigator.pushNamed(context, '/companion')),
            const SizedBox(height: 10),
            _buildTile('Exportar mis datos', 'Descarga tu historial',
                Icons.download_rounded, () {}),
            const SizedBox(height: 10),
            _buildTile('Eliminar cuenta', 'Eliminar todos mis datos',
                Icons.delete_forever_rounded, () {},
                color: AppColors.badgeHigh),
            const SizedBox(height: 24),

            AppButton(
              label: 'Cerrar sesión',
              style: AppButtonStyle.outline,
              width: double.infinity,
              onPressed: () async {
                await ApiService.clearToken();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitch(String title, String subtitle, IconData icon, bool value,
      ValueChanged<bool> onChanged) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: AppTextStyles.body
                      .copyWith(fontWeight: FontWeight.w600)),
              Text(subtitle, style: AppTextStyles.caption),
            ],
          )),
          Switch(value: value, onChanged: onChanged, activeColor: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildTile(String title, String subtitle, IconData icon,
      VoidCallback onTap, {Color? color}) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: (color ?? AppColors.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color ?? AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: AppTextStyles.body
                      .copyWith(fontWeight: FontWeight.w600, color: color)),
              Text(subtitle, style: AppTextStyles.caption),
            ],
          )),
          Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
        ],
      ),
    );
  }
}
