import 'package:flutter/material.dart';
import '../models/cep_model.dart';

class CepInfoCard extends StatelessWidget {
  final CepModel cep;

  const CepInfoCard({Key? key, required this.cep}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CEP
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(flex: 2, child: Text('CEP:', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 3, child: Text((cep.cep ?? '').isEmpty ? 'N/A' : cep.cep!, style: const TextStyle(color: Colors.black87))),
                ],
              ),
            ),
            const Divider(),
            
            // Logradouro
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(flex: 2, child: Text('Logradouro:', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 3, child: Text((cep.logradouro ?? '').isEmpty ? 'N/A' : cep.logradouro!, style: const TextStyle(color: Colors.black87))),
                ],
              ),
            ),
            const Divider(),
            
            // Bairro
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(flex: 2, child: Text('Bairro:', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 3, child: Text((cep.bairro ?? '').isEmpty ? 'N/A' : cep.bairro!, style: const TextStyle(color: Colors.black87))),
                ],
              ),
            ),
            const Divider(),

            // Localidade/UF
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(flex: 2, child: Text('Localidade/UF:', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 3, child: Text('${cep.localidade} - ${cep.uf}', style: const TextStyle(color: Colors.black87))),
                ],
              ),
            ),
            
            // Região e DDD (adicionados recentemente)
            if (cep.regiao != null && cep.regiao!.isNotEmpty) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(flex: 2, child: Text('Região:', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(flex: 3, child: Text(cep.regiao!, style: const TextStyle(color: Colors.black87))),
                  ],
                ),
              ),
            ],
            
            if (cep.ddd != null && cep.ddd!.isNotEmpty) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(flex: 2, child: Text('DDD:', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(flex: 3, child: Text(cep.ddd!, style: const TextStyle(color: Colors.black87))),
                  ],
                ),
              ),
            ],

            // Complemento
            if (cep.complemento != null && cep.complemento!.isNotEmpty) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(flex: 2, child: Text('Complemento:', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(flex: 3, child: Text(cep.complemento!, style: const TextStyle(color: Colors.black87))),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
