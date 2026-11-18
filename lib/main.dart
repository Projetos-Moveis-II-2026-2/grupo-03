import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'views/recuperacao_senha.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'controllers/progresso_controller.dart';
import 'models/sessao_usuario.dart';
import 'repositories/flashcard_repository.dart';
import 'repositories/progresso_repository.dart';
import 'repositories/questao_repository.dart';
import 'views/home_screen.dart';
import 'views/login_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final retorno = Uri.base;
  final recuperando =
      kIsWeb && retorno.queryParameters['fluxo'] == 'recuperacao';
  await Supabase.initialize(
    authOptions: FlutterAuthClientOptions(detectSessionInUri: !recuperando),
    url: 'https://fknntomvtscxmnfuxmqe.supabase.co',
    publishableKey: 'sb_publishable_kJoT334nomzZI9wFGcGX6w_Z--aRJ4E',
  );
  final prefs = await SharedPreferences.getInstance();
  await SessaoUsuario.instance.carregar(prefs);
  if (recuperando) {
    await SessaoUsuario.instance.abrirRecuperacao(retorno);
    await SystemNavigator.routeInformationUpdated(
      uri: Uri.parse('/'),
      replace: true,
    );
  }
  final flashcardRepo = FlashcardRepository(prefs: prefs);
  final questaoRepo = QuestaoRepository(prefs: prefs);
  // Persistência local do progresso. Na Etapa 3, trocar por uma
  // implementação remota de ProgressoRepository (Supabase).
  final progressoRepo = ProgressoRepositoryLocal(prefs: prefs);
  runApp(
    MyApp(
      sessao: SessaoUsuario.instance,
      flashcardRepository: flashcardRepo,
      questaoRepository: questaoRepo,
      progressoRepository: progressoRepo,
    ),
  );
}

class MyApp extends StatelessWidget {
  final SessaoUsuario? sessao;
  final FlashcardRepository? flashcardRepository;
  final QuestaoRepository? questaoRepository;
  final ProgressoRepository? progressoRepository;

  const MyApp({
    super.key,
    this.sessao,
    this.flashcardRepository,
    this.questaoRepository,
    this.progressoRepository,
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
        // Recarrega o progresso sempre que o usuário logado muda.
        ChangeNotifierProxyProvider<SessaoUsuario, ProgressoController>(
          create: (_) => ProgressoController(
            progressoRepository ?? ProgressoRepositoryLocal(),
          ),
          update: (_, sessao, controller) {
            final progresso = controller!;
            progresso.carregarUsuario(sessao.estaLogado ? sessao.email : '');
            return progresso;
          },
        ),
      ],
      child: Consumer<SessaoUsuario>(
        builder: (_, usuario, _) => MaterialApp(
          key: ValueKey((usuario.id, usuario.recuperacao)),
          title: 'FocoDeck',
          theme: AppTheme.lightTheme,
          home: usuario.recuperacao != null
              ? RecuperacaoSenha(etapa: usuario.recuperacao!)
              : usuario.estaLogado
              ? const HomeScreen()
              : const LoginScreen(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
