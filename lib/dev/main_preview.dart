// Ponto de entrada APENAS para testes locais, sem Supabase.
//
// Abre o app direto na Home, pulando o login, para testar dashboard,
// flashcards, simulado, recompensas, recomendação adaptativa e a geração
// automática de decks (Datamuse) sem precisar das chaves do Supabase.
//
//   flutter run -d chrome -t lib/dev/main_preview.dart
//
// Limitações: login/logout/perfil não funcionam (dependem do Supabase
// Auth) e as telas de estudo mostram o aviso "Sem conexão" porque o
// conteúdo do Supabase não carrega; os cartões embutidos e os decks
// gerados funcionam normalmente. O build oficial continua usando
// `lib/main.dart`.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/progresso_controller.dart';
import '../repositories/flashcard_repository.dart';
import '../repositories/progresso_repository.dart';
import '../repositories/questao_repository.dart';
import '../theme/app_theme.dart';
import '../views/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final progresso = ProgressoController(ProgressoRepositoryLocal(prefs: prefs));
  await progresso.carregarUsuario('preview-local');

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => FlashcardRepository(prefs: prefs)),
        Provider(create: (_) => QuestaoRepository(prefs: prefs)),
        ChangeNotifierProvider.value(value: progresso),
      ],
      child: MaterialApp(
        title: 'FocoDeck (preview)',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const HomeScreen(),
      ),
    ),
  );
}
