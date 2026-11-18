import 'package:dio/dio.dart';

/// Cliente PostgREST. Configure com --dart-define=SUPABASE_URL=... e
/// --dart-define=SUPABASE_ANON_KEY=... no ambiente da aplicação.
class ConteudoApi {
  static const _url = String.fromEnvironment('SUPABASE_URL');
  static const _anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  final Dio _dio;

  ConteudoApi({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: _url.isEmpty
                  ? 'https://invalid.local'
                  : '${_url.replaceFirst(RegExp(r'/$'), '')}/rest/v1',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
              headers: {
                if (_anonKey.isNotEmpty) 'apikey': _anonKey,
                if (_anonKey.isNotEmpty) 'Authorization': 'Bearer $_anonKey',
                'Accept': 'application/json',
              },
            ),
          );

  bool get configured => _url.isNotEmpty && _anonKey.isNotEmpty;

  Future<List<Map<String, dynamic>>> listar(String tabela) async {
    if (!configured) {
      throw StateError(
        'A conexão com o serviço de conteúdo não está configurada.',
      );
    }
    final response = await _dio.get<List<dynamic>>(
      '/$tabela',
      queryParameters: {'select': '*'},
    );
    return (response.data ?? const [])
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList(growable: false);
  }
}
