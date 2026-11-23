import 'package:dio/dio.dart';

/// Palavra sugerida pelo Datamuse para um tema.
class PalavraCandidata {
  final String palavra;

  /// Ocorrências por milhão de palavras (indicador de quão comum é).
  final double frequencia;

  /// Classes gramaticais informadas (`n`, `v`, `adj`, `adv`).
  final Set<String> classes;

  const PalavraCandidata({
    required this.palavra,
    required this.frequencia,
    this.classes = const {},
  });
}

/// Fonética e frase de exemplo obtidas no dicionário.
class DetalhesPalavra {
  final String fonetica;
  final String exemplo;

  const DetalhesPalavra({required this.fonetica, required this.exemplo});
}

/// Falha ao consultar as APIs públicas de vocabulário.
class VocabularioApiException implements Exception {
  final String mensagem;
  const VocabularioApiException(this.mensagem);

  @override
  String toString() => mensagem;
}

/// Cliente das APIs públicas e gratuitas (sem chave) usadas na geração
/// automática de conteúdo:
///
/// - **Datamuse** (`api.datamuse.com`): palavras relacionadas a um tema.
/// - **Free Dictionary** (`dictionaryapi.dev`): fonética e frase de exemplo.
/// - **MyMemory** (`mymemory.translated.net`): tradução inglês → português.
class VocabularioApi {
  static const String _datamuse = 'https://api.datamuse.com/words';
  static const String _dicionario =
      'https://api.dictionaryapi.dev/api/v2/entries/en';
  static const String _tradutor = 'https://api.mymemory.translated.net/get';

  final Dio _dio;

  VocabularioApi({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
              headers: {'Accept': 'application/json'},
            ),
          );

  /// Palavras do tema, na ordem de relevância do Datamuse: primeiro as de
  /// sentido parecido (`ml`), depois as associadas ao tema (`rel_trg`).
  Future<List<PalavraCandidata>> buscarPalavras(
    String tema, {
    int maximo = 40,
  }) async {
    final consultas = await Future.wait([
      _consultarDatamuse({'ml': tema, 'md': 'fp', 'max': maximo}),
      _consultarDatamuse({'rel_trg': tema, 'md': 'fp', 'max': maximo}),
    ]);
    final vistas = <String>{};
    return [
      for (final lista in consultas)
        for (final candidata in lista)
          if (vistas.add(candidata.palavra)) candidata,
    ];
  }

  Future<List<PalavraCandidata>> _consultarDatamuse(
    Map<String, Object> parametros,
  ) async {
    try {
      final resposta = await _dio.get<List<dynamic>>(
        _datamuse,
        queryParameters: parametros,
      );
      return (resposta.data ?? const [])
          .whereType<Map>()
          .map(_lerCandidata)
          .whereType<PalavraCandidata>()
          .toList();
    } on DioException {
      throw const VocabularioApiException(
        'Não foi possível buscar palavras agora.',
      );
    }
  }

  static PalavraCandidata? _lerCandidata(Map item) {
    final palavra = item['word'];
    if (palavra is! String || palavra.isEmpty) return null;
    final tags = (item['tags'] as List? ?? const []).whereType<String>();
    var frequencia = 0.0;
    final classes = <String>{};
    for (final tag in tags) {
      if (tag.startsWith('f:')) {
        frequencia = double.tryParse(tag.substring(2)) ?? 0;
      } else if (const {'n', 'v', 'adj', 'adv'}.contains(tag)) {
        classes.add(tag);
      }
    }
    return PalavraCandidata(
      palavra: palavra,
      frequencia: frequencia,
      classes: classes,
    );
  }

  /// Fonética (IPA) e a primeira frase de exemplo do dicionário.
  /// Retorna `null` se a palavra não existir ou não tiver exemplo.
  Future<DetalhesPalavra?> buscarDetalhes(String palavra) async {
    try {
      final resposta = await _dio.get<List<dynamic>>(
        '$_dicionario/${Uri.encodeComponent(palavra)}',
      );
      final entradas = (resposta.data ?? const []).whereType<Map>().toList();
      String? fonetica;
      String? exemplo;
      for (final entrada in entradas) {
        fonetica ??= _textoNaoVazio(entrada['phonetic']);
        for (final f in (entrada['phonetics'] as List? ?? const [])) {
          if (f is Map) fonetica ??= _textoNaoVazio(f['text']);
        }
        for (final significado in (entrada['meanings'] as List? ?? const [])) {
          if (significado is! Map) continue;
          for (final def in (significado['definitions'] as List? ?? const [])) {
            if (def is Map) exemplo ??= _textoNaoVazio(def['example']);
          }
        }
      }
      if (exemplo == null) return null;
      return DetalhesPalavra(fonetica: fonetica ?? '', exemplo: exemplo);
    } on DioException catch (e) {
      // 404 = palavra sem verbete: apenas descarta a candidata.
      if (e.response?.statusCode == 404) return null;
      throw const VocabularioApiException(
        'Não foi possível consultar o dicionário agora.',
      );
    }
  }

  /// Traduz um texto do inglês para o português do Brasil.
  /// Retorna `null` se a tradução não estiver disponível (ex.: cota esgotada).
  Future<String?> traduzir(String texto) async {
    try {
      final resposta = await _dio.get<Map<String, dynamic>>(
        _tradutor,
        queryParameters: {'q': texto, 'langpair': 'en|pt-BR'},
      );
      final dados = resposta.data;
      if (dados == null || dados['quotaFinished'] == true) return null;
      if (dados['responseStatus'] != 200) return null;
      final traduzido = _textoNaoVazio(
        (dados['responseData'] as Map?)?['translatedText'],
      );
      // MyMemory devolve o próprio texto quando não sabe traduzir.
      if (traduzido == null || traduzido.toLowerCase() == texto.toLowerCase()) {
        return null;
      }
      return traduzido;
    } on DioException {
      throw const VocabularioApiException('Não foi possível traduzir agora.');
    }
  }

  static String? _textoNaoVazio(Object? valor) {
    if (valor is! String) return null;
    final texto = valor.trim();
    return texto.isEmpty ? null : texto;
  }
}
