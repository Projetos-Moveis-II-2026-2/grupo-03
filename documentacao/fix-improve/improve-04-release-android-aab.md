# IMPROVE 04 — Configuração de Release Android (`.aab`)

## Objetivo
Preparar a identidade e assinatura do pacote Android para geração do Android App Bundle (`.aab`) exigido na entrega final.

## Arquivos
- `android/app/build.gradle.kts`
- `android/app/src/main/AndroidManifest.xml`

## Ações
1. Atualizar `android:label` para `"FocoDeck"` no `AndroidManifest.xml`.
2. Definir `applicationId` único em `build.gradle.kts` e configurar leitura de `key.properties` (fora do Git) para assinatura `release`.
3. Validar compilação com `flutter build appbundle --release`.
