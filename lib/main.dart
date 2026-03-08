// ════════════════════════════════════════════════════════════
//  FLORECE APP — main.dart
//  Diario emocional para mujeres
//  Arquitectura: Flutter + AWS (Cognito, Lambda, DynamoDB, Bedrock, SNS)
// ════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/auth/auth_screens.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/diary/diary_screen.dart';
import 'screens/habits/habits_cycle_goals_screens.dart';
import 'screens/agenda/agenda_growth_screens.dart';
import 'screens/companion/companion_support_settings_screens.dart';

void main() {
  runApp(const FloreceApp());
}

class FloreceApp extends StatelessWidget {
  const FloreceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Florece',
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      initialRoute: '/login',
      routes: {
        // ── Auth (Dev 1) ──────────────────────────────
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/onboarding': (_) => const OnboardingScreen(),

        // ── Dashboard (Dev 3) ─────────────────────────
        '/dashboard': (_) => const DashboardScreen(),

        // ── Diario Emocional (Dev 1) ──────────────────
        '/diary': (_) => const DiaryScreen(),

        // ── Hábitos, Ciclo, Metas (Dev 2) ─────────────
        '/habits': (_) => const HabitsScreen(),
        '/cycle': (_) => const CycleScreen(),
        '/goals': (_) => const GoalsScreen(),

        // ── Agenda & Crecimiento (Dev 3) ──────────────
        '/agenda': (_) => const AgendaScreen(),
        '/growth': (_) => const GrowthScreen(),

        // ── Modo Compañía (Dev 4) ─────────────────────
        '/companion': (_) => const CompanionScreen(),
        '/support': (_) => const SupportChatScreen(),
        '/settings': (_) => const SettingsScreen(),
      },
    );
  }
}
