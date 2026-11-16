import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/sessao_usuario.dart';
import 'repositories/flashcard_repository.dart';
import 'repositories/questao_repository.dart';
import 'views/home_screen.dart';
import 'views/login_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await SessaoUsuario.instance.carregar(prefs);
  final flashcardRepo = FlashcardRepository(prefs: prefs);
  final questaoRepo = QuestaoRepository(prefs: prefs);
  runApp(MyApp(sessao: SessaoUsuario.instance, flashcardRepository: flashcardRepo, questaoRepository: questaoRepo));
}

class MyApp extends StatelessWidget {
  final SessaoUsuario? sessao;
  final FlashcardRepository? flashcardRepository;
  final QuestaoRepository? questaoRepository;

  const MyApp({
    super.key,
    this.sessao,
    this.flashcardRepository,
    this.questaoRepository,
  });

  @override
  Widget build(BuildContext context) {
    final sessaoAtiva = sessao ?? SessaoUsuario.instance;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SessaoUsuario>.value(value: sessaoAtiva),
        Provider<FlashcardRepository>(
          create: (_) => flashcardRepository ?? FlashcardRepository(),
        ),
        Provider<QuestaoRepository>(
          create: (_) => questaoRepository ?? QuestaoRepository(),
        ),
      ],
      child: MaterialApp(
        title: 'FocoDeck',
        theme: AppTheme.lightTheme,
        home: sessaoAtiva.sessaoRestaurada
            ? const HomeScreen()
            : const LoginScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
