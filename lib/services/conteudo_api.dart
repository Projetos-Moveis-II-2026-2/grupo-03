import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Cliente PostgREST compartilhando configuração e sessão com o Supabase Auth.
class ConteudoApi {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  final Dio _dio;
  final String _url;
  final String _publishableKey;
  final String? Function()? _accessTokenProvider;

  ConteudoApi({
    Dio? dio,
    String? url,
    String? publishableKey,
    String? Function()? accessTokenProvider,
  })
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
              headers: {'Accept': 'application/json'},
            ),
          ),
      _url = url ?? supabaseUrl,
      _publishableKey = publishableKey ?? supabasePublishableKey,
      _accessTokenProvider = accessTokenProvider;

  SupabaseClient? get _activeClient {
    if (_url.isEmpty || _publishableKey.isEmpty) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  bool get configured => _url.isNotEmpty && _publishableKey.isNotEmpty;

  Future<List<Map<String, dynamic>>> listar(String tabela) async {
    if (!configured) {
      throw StateError(
        'A conexão com o serviço de conteúdo não está configurada.',
      );
    }
    final accessToken = _accessTokenProvider?.call() ??
        _activeClient?.auth.currentSession?.accessToken;
    final response = await _dio.get<List<dynamic>>(
      '${_url.replaceFirst(RegExp(r'/$'), '')}/rest/v1/$tabela',
      queryParameters: {'select': '*'},
      options: Options(
        headers: {
          'apikey': _publishableKey,
          'Authorization':
              'Bearer ${accessToken ?? _publishableKey}',
          'Accept': 'application/json',
        },
      ),
    );
    return (response.data ?? const [])
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList(growable: false);
  }
}
