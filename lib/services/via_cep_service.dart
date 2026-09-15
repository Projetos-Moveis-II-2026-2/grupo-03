import 'package:dio/dio.dart';
import '../models/cep_model.dart';

class ViaCepService {
  final Dio _dio = Dio();

  Future<CepModel?> fetchCep(String cep) async {
    try {
      final response = await _dio.get('https://viacep.com.br/ws/$cep/json/');
      if (response.statusCode == 200) {
        if (response.data['erro'] == true) {
          return null;
        }
        return CepModel.fromJson(response.data);
      }
    } catch (e) {
      throw Exception('Falha ao buscar CEP. Verifique sua conexão e tente novamente.');
    }
    return null;
  }
}
