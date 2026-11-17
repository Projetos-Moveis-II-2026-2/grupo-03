import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_com_api/services/recompensa_service.dart';
import 'package:projeto_com_api/widgets/recompensa_card.dart';

void main() {
  testWidgets('RecompensaCard exibe mensagem em inglês, tradução e conquista', (
    tester,
  ) async {
    final mensagem = RecompensaService.mensagensIncentivo.first;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecompensaCard(
            resultado: ResultadoRecompensa(
              mensagem: mensagem,
              conquista: RecompensaService.wordMaster,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(mensagem.expressaoIngles), findsOneWidget);
    expect(find.text(mensagem.traducao), findsOneWidget);
    expect(find.text('Nova conquista: Word Master!'), findsOneWidget);
  });
}
