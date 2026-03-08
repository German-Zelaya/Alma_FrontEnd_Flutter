// ════════════════════════════════════════════════════════════
//  DEV 1 — AUTENTICACIÓN
//  Endpoints: POST /auth/register  POST /auth/login
//  Hook expuesto: useAuth() → user.id, token
// ════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

// ─── PANTALLA DE LOGIN ────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  Future<void> _onLogin() async {
    setState(() => _loading = true);
    // TODO: llamar POST /auth/login con Cognito/Amplify
    // final result = await authService.login(_emailCtrl.text, _passCtrl.text);
    // Navegar a Dashboard si exitoso
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _loading = false);
    if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo / marca
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 72, height: 72,
                      decoration: AppDecorations.primaryContainer,
                      child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 36),
                    ),
                    const SizedBox(height: 16),
                    const Text('Florece', style: AppTextStyles.heading1),
                    const SizedBox(height: 4),
                    const Text('Tu espacio de bienestar emocional', style: AppTextStyles.bodySecondary),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              const Text('Iniciar sesión', style: AppTextStyles.heading2),
              const SizedBox(height: 24),

              AppInput(
                hint: 'correo@ejemplo.com',
                label: 'Correo electrónico',
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primaryLight),
              ),
              const SizedBox(height: 16),
              AppInput(
                hint: '••••••••',
                label: 'Contraseña',
                controller: _passCtrl,
                obscureText: _obscure,
                prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primaryLight),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.textLight),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text('¿Olvidaste tu contraseña?', style: TextStyle(color: AppColors.primary)),
                ),
              ),
              const SizedBox(height: 24),
              AppButton(label: 'Iniciar sesión', onPressed: _onLogin, isLoading: _loading, width: double.infinity),
              const SizedBox(height: 16),
              AppButton(
                label: 'Crear cuenta',
                style: AppButtonStyle.outline,
                width: double.infinity,
                onPressed: () => Navigator.pushNamed(context, '/register'),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('o continúa con', style: AppTextStyles.caption)),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),
              _SocialButton(label: 'Google', icon: Icons.g_mobiledata_rounded, onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  const _SocialButton({required this.label, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, height: 50,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primaryLight.withOpacity(0.4)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: Icon(icon, color: AppColors.primary),
        label: Text('Continuar con $label', style: AppTextStyles.bodySecondary),
      ),
    );
  }
}

// ─── PANTALLA DE REGISTRO ─────────────────────────────────
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _onRegister() async {
    setState(() => _loading = true);
    // TODO: llamar POST /auth/register con Cognito
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _loading = false);
    if (mounted) Navigator.pushReplacementNamed(context, '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        title: const Text('Crear cuenta'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppDecorations.gradientCard,
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 28),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('Bienvenida a tu espacio seguro de crecimiento emocional 💜', style: AppTextStyles.bodySecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              AppInput(hint: 'Tu nombre', label: 'Nombre', controller: _nameCtrl,
                  prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primaryLight)),
              const SizedBox(height: 16),
              AppInput(hint: 'correo@ejemplo.com', label: 'Correo electrónico', controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primaryLight)),
              const SizedBox(height: 16),
              AppInput(hint: '••••••••', label: 'Contraseña', controller: _passCtrl,
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primaryLight)),
              const SizedBox(height: 32),
              AppButton(label: 'Crear mi cuenta', onPressed: _onRegister, isLoading: _loading, width: double.infinity),
              const SizedBox(height: 16),
              Center(
                child: RichText(
                  text: TextSpan(
                    style: AppTextStyles.caption,
                    children: [
                      const TextSpan(text: 'Al registrarte aceptas nuestros '),
                      TextSpan(text: 'Términos de uso', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── PANTALLA DE ONBOARDING ───────────────────────────────
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageCtrl = PageController();
  int _page = 0;

  // Preferencias del usuario
  String _userName = '';
  String? _selectedGoal;
  DateTime? _lastPeriodDate;
  int _cycleLength = 28;

  final _goals = ['Bienestar emocional', 'Productividad', 'Salud física', 'Crecimiento personal', 'Equilibrio vida-trabajo'];

  void _next() {
    if (_page < 2) {
      _pageCtrl.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      // TODO: guardar preferencias en DynamoDB → POST /users/preferences
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: Row(
                children: List.generate(3, (i) => Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: i <= _page ? AppColors.primary : AppColors.primaryLight.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                )),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                onPageChanged: (p) => setState(() => _page = p),
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _OnboardPage1(onNameChanged: (v) => _userName = v),
                  _OnboardPage2(goals: _goals, selected: _selectedGoal, onSelect: (g) => setState(() => _selectedGoal = g)),
                  _OnboardPage3(onDatePicked: (d) => _lastPeriodDate = d, cycleLength: _cycleLength, onCycleChanged: (v) => setState(() => _cycleLength = v)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: AppButton(
                label: _page == 2 ? '¡Empezar mi viaje! 🌸' : 'Continuar',
                onPressed: _next, width: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage1 extends StatelessWidget {
  final ValueChanged<String> onNameChanged;
  const _OnboardPage1({required this.onNameChanged});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🌸', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 16),
          const Text('¡Hola! ¿Cómo te llamas?', style: AppTextStyles.heading1),
          const SizedBox(height: 8),
          const Text('Nos gusta personalizar tu experiencia', style: AppTextStyles.bodySecondary),
          const SizedBox(height: 32),
          AppInput(hint: 'Tu nombre', onChanged: onNameChanged),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class _OnboardPage2 extends StatelessWidget {
  final List<String> goals;
  final String? selected;
  final ValueChanged<String> onSelect;
  const _OnboardPage2({required this.goals, this.selected, required this.onSelect});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🎯', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 16),
          const Text('¿Cuál es tu meta principal?', style: AppTextStyles.heading1),
          const SizedBox(height: 24),
          ...goals.map((g) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => onSelect(g),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: selected == g ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: selected == g ? AppColors.primary : AppColors.primaryLight.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Text(g, style: AppTextStyles.body.copyWith(color: selected == g ? Colors.white : AppColors.textPrimary, fontWeight: selected == g ? FontWeight.w600 : FontWeight.normal)),
                    const Spacer(),
                    if (selected == g) const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }
}

class _OnboardPage3 extends StatelessWidget {
  final ValueChanged<DateTime> onDatePicked;
  final int cycleLength;
  final ValueChanged<int> onCycleChanged;
  const _OnboardPage3({required this.onDatePicked, required this.cycleLength, required this.onCycleChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🌙', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 16),
          const Text('Tu ciclo menstrual', style: AppTextStyles.heading1),
          const SizedBox(height: 8),
          const Text('Esta información es privada y nos ayuda a personalizar tus recomendaciones', style: AppTextStyles.bodySecondary),
          const SizedBox(height: 32),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Inicio de último período', style: AppTextStyles.body),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now().subtract(const Duration(days: 60)), lastDate: DateTime.now());
                    if (d != null) onDatePicked(d);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(12)),
                    child: const Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 18),
                        SizedBox(width: 10),
                        Text('Seleccionar fecha', style: AppTextStyles.bodySecondary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Duración del ciclo', style: AppTextStyles.body),
                    Text('$cycleLength días', style: AppTextStyles.body.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ],
                ),
                Slider(
                  value: cycleLength.toDouble(),
                  min: 21, max: 35, divisions: 14,
                  activeColor: AppColors.primary,
                  onChanged: (v) => onCycleChanged(v.round()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Extensión para AppInput con onChanged
extension AppInputExt on AppInput {
  // Esta extensión no se puede hacer en Flutter directamente,
  // ver la clase abajo como alternativa
}

// AppInput con soporte onChanged
class AppInput extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? label;
  final int maxLines;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const AppInput({
    super.key,
    required this.hint,
    this.controller,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.label,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
          ),
          style: AppTextStyles.body,
        ),
      ],
    );
  }
}
