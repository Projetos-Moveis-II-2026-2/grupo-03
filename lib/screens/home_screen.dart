import 'package:flutter/material.dart';
import '../models/cep_model.dart';
import '../services/via_cep_service.dart';
import '../widgets/cep_info_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _cepController = TextEditingController();
  final ViaCepService _cepService = ViaCepService();
  
  CepModel? _cepModel;
  bool _isLoading = false;
  String? _errorMessage;

  void _searchCep() async {
    final cep = _cepController.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cep.length != 8) {
      setState(() {
        _errorMessage = 'Por favor, digite um CEP válido (8 dígitos).';
        _cepModel = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _cepModel = null;
    });

    try {
      final result = await _cepService.fetchCep(cep);
      setState(() {
        if (result != null) {
          _cepModel = result;
        } else {
          _errorMessage = 'CEP não encontrado.';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _cepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscador de CEP'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _cepController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Digite o CEP',
                hintText: 'Ex: 01001000',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchCep,
                ),
              ),
              onSubmitted: (_) => _searchCep(),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade900),
                  textAlign: TextAlign.center,
                ),
              )
            else if (_cepModel != null)
              CepInfoCard(cep: _cepModel!),
          ],
        ),
      ),
    );
  }
}
