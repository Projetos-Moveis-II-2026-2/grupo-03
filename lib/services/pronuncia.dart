/// Converte fonética IPA para a forma aportuguesada usada nos decks fixos
/// (ex.: `/ˈkʌltɪveɪt/` → `KÂL-ti-vêit`): sílabas separadas por hífen e a
/// sílaba tônica em maiúsculas.
///
/// Textos que não são IPA voltam inalterados. Se houver um símbolo
/// desconhecido, devolve vazio: é melhor não mostrar do que mostrar IPA.
String aportuguesarFonetica(String fonetica) {
  final original = fonetica.trim();
  if (!original.startsWith('/') && !original.startsWith('[')) return original;

  final ipa = original
      .split(RegExp(r'[,;]')) // só a primeira variante
      .first
      .replaceAll(RegExp(r'\([^)]*\)'), '') // sons opcionais
      .replaceAll(RegExp(r'[/\[\]͜͡\s]'), '')
      .replaceAll("'", 'ˈ');

  final sons = <_Som>[];
  var quebra = false;
  var tonica = false;
  var i = 0;
  while (i < ipa.length) {
    final simbolo = ipa[i];
    if (simbolo == 'ˈ' || simbolo == 'ˌ' || simbolo == '.') {
      quebra = true;
      tonica = simbolo == 'ˈ';
      i++;
      continue;
    }
    String? chave;
    for (final tamanho in const [3, 2, 1]) {
      if (i + tamanho > ipa.length) continue;
      final trecho = ipa.substring(i, i + tamanho);
      if (_vogais.containsKey(trecho) || _consoantes.containsKey(trecho)) {
        chave = trecho;
        break;
      }
    }
    if (chave == null) return '';
    final vogal = _vogais[chave];
    sons.add(_Som(vogal ?? _consoantes[chave]!, vogal != null, quebra, tonica));
    quebra = false;
    tonica = false;
    i += chave.length;
  }

  final silabas = _separarSilabas(sons);
  if (silabas.isEmpty) return '';
  return [
    for (final s in silabas)
      _escrever(s, silabas.length == 1 || s.any((som) => som.tonica)),
  ].join('-');
}

class _Som {
  final String texto;
  final bool vogal;

  /// Há uma marca de início de sílaba antes deste som.
  final bool quebra;
  final bool tonica;

  const _Som(this.texto, this.vogal, this.quebra, this.tonica);
}

List<List<_Som>> _separarSilabas(List<_Som> sons) {
  final vogais = [
    for (var i = 0; i < sons.length; i++)
      if (sons[i].vogal) i,
  ];
  if (vogais.isEmpty) return sons.isEmpty ? [] : [sons];
  final silabas = <List<_Som>>[];
  var inicio = 0;
  for (var v = 0; v + 1 < vogais.length; v++) {
    final de = vogais[v] + 1;
    final ate = vogais[v + 1];
    var corte = -1;
    for (var i = de; i <= ate; i++) {
      if (sons[i].quebra) corte = i;
    }
    if (corte < 0) {
      corte = ate;
      if (ate - de >= 1 && sons[ate - 1].texto != 'ng') corte = ate - 1;
      if (ate - de >= 2 &&
          _encontros.contains(sons[ate - 2].texto + sons[ate - 1].texto)) {
        corte = ate - 2;
      }
    }
    silabas.add(sons.sublist(inicio, corte));
    inicio = corte;
  }
  silabas.add(sons.sublist(inicio));
  return silabas;
}

String _escrever(List<_Som> silaba, bool tonica) {
  final texto = silaba
      .map((s) => s.texto)
      .join()
      // "g" antes de e/i soaria como "j" em português.
      .replaceAllMapped(RegExp('g(?=[eéêi])'), (_) => 'gu');
  return tonica ? texto.toUpperCase() : texto;
}

const Set<String> _encontros = {
  'pr', 'br', 'tr', 'dr', 'kr', 'gr', 'fr', 'thr', //
  'pl', 'bl', 'kl', 'gl', 'fl', 'sl',
  'sp', 'st', 'sk', 'sm', 'sn', 'ku', 'gu', 'tu',
};

const Map<String, String> _vogais = {
  'eɪ': 'êi', 'aɪ': 'ái', 'ʌɪ': 'ái', 'ɑɪ': 'ái', 'ɔɪ': 'ói', //
  'oʊ': 'ôu', 'əʊ': 'ôu', 'aʊ': 'áu', 'ʌʊ': 'áu', 'ɑʊ': 'áu',
  'ɪə': 'iâ', 'iə': 'iâ', 'eə': 'éâ', 'ɛə': 'éâ', 'ʊə': 'uâ',
  'iː': 'ii', 'uː': 'uu', 'ɑː': 'á', 'ɔː': 'ó', 'ɜː': 'âr', 'ɜːr': 'âr',
  'ɜːɹ': 'âr', 'ɜɹ': 'âr', 'ɜr': 'âr', 'əɹ': 'âr', 'ər': 'âr',
  'eː': 'é', 'ɛː': 'é', 'aː': 'á', 'oː': 'ô', 'ɒː': 'ó', 'əː': 'âr',
  'i': 'i', 'ɪ': 'i', 'ᵻ': 'i', 'e': 'é', 'ɛ': 'é', 'æ': 'é',
  'a': 'á', 'ɑ': 'á', 'ɒ': 'ó', 'ɔ': 'ó', 'o': 'ô', 'u': 'u', 'ʊ': 'u',
  'ʉ': 'u', 'ʉː': 'uu', 'ʌ': 'â', 'ɐ': 'â', 'ə': 'â', 'ɘ': 'â',
  'ɜ': 'âr', 'ɝ': 'âr', 'ɚ': 'âr', 'ɝː': 'âr',
  'n̩': 'ân', 'l̩': 'âl', 'm̩': 'âm', 'ɫ̩': 'âl',
};

const Map<String, String> _consoantes = {
  'tʃ': 'tch', 'dʒ': 'dj', 'ʧ': 'tch', 'ʤ': 'dj', 'ʃ': 'ch', 'ʒ': 'j', //
  'θ': 'th', 'ð': 'th', 'ŋ': 'ng', 'ŋɡ': 'ng', 'ŋg': 'ng', 'ŋk': 'nk',
  'ɹ': 'r', 'r': 'r', 'ɾ': 'r', 'ɻ': 'r', 'j': 'i', 'w': 'u', 'ʍ': 'u',
  'h': 'h', 'ɡ': 'g', 'g': 'g', 'k': 'k', 'p': 'p', 'b': 'b', 't': 't',
  'd': 'd', 'f': 'f', 'v': 'v', 's': 's', 'z': 'z', 'm': 'm', 'n': 'n',
  'l': 'l', 'ɫ': 'l', 'ʔ': 't',
};
