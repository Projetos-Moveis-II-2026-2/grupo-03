/// Palavra de um tema pronto, de nível iniciante.
typedef PalavraPronta = ({
  String termo,
  String fonetica,
  String traducao,
  String exemplo,
  String traducaoExemplo,
});

PalavraPronta _p(
  String termo,
  String fonetica,
  String traducao,
  String exemplo,
  String traducaoExemplo,
) => (
  termo: termo,
  fonetica: fonetica,
  traducao: traducao,
  exemplo: exemplo,
  traducaoExemplo: traducaoExemplo,
);

/// Conteúdo fixo dos temas sugeridos (chave = tema em inglês).
///
/// Garante palavras do tema e de nível iniciante, sem depender da qualidade
/// dos resultados das APIs. Cada tema tem 5 palavras (= 1 bloco curto).
final Map<String, List<PalavraPronta>> temasProntos = {
  'travel': [
    _p('Trip', 'TRIP', 'Viagem', 'We had a great trip.',
        'Nós fizemos uma ótima viagem.'),
    _p('Ticket', 'TI-kât', 'Passagem', 'I bought a bus ticket.',
        'Eu comprei uma passagem de ônibus.'),
    _p('Airport', 'ÉR-pórt', 'Aeroporto', 'The airport is near the city.',
        'O aeroporto fica perto da cidade.'),
    _p('Suitcase', 'SUT-kêis', 'Mala', 'My suitcase is very heavy.',
        'Minha mala está muito pesada.'),
    _p('Passport', 'PÉS-pórt', 'Passaporte', 'Where is my passport?',
        'Onde está meu passaporte?'),
  ],
  'work': [
    _p('Job', 'DJÓB', 'Emprego', 'She has a new job.',
        'Ela tem um emprego novo.'),
    _p('Office', 'Ó-fis', 'Escritório', 'I work in a small office.',
        'Eu trabalho em um escritório pequeno.'),
    _p('Boss', 'BÓS', 'Chefe', 'My boss is very kind.',
        'Meu chefe é muito gentil.'),
    _p('Meeting', 'MÍI-ting', 'Reunião', 'We have a meeting today.',
        'Nós temos uma reunião hoje.'),
    _p('Team', 'TIIM', 'Equipe', 'Our team works well together.',
        'Nossa equipe trabalha bem junta.'),
  ],
  'food': [
    _p('Bread', 'BRÉD', 'Pão', 'I eat bread every morning.',
        'Eu como pão toda manhã.'),
    _p('Rice', 'RÁIS', 'Arroz', 'He likes rice and beans.',
        'Ele gosta de arroz e feijão.'),
    _p('Chicken', 'TCHI-kân', 'Frango', 'We had chicken for lunch.',
        'Nós comemos frango no almoço.'),
    _p('Cheese', 'TCHIIZ', 'Queijo', 'I want a cheese sandwich.',
        'Eu quero um sanduíche de queijo.'),
    _p('Soup', 'SUUP', 'Sopa', 'The soup is hot.', 'A sopa está quente.'),
  ],
  'health': [
    _p('Doctor', 'DÓK-târ', 'Médico', 'I need to see a doctor.',
        'Eu preciso ir a um médico.'),
    _p('Medicine', 'MÉ-di-sân', 'Remédio', 'Take your medicine after lunch.',
        'Tome seu remédio depois do almoço.'),
    _p('Sleep', 'SLIIP', 'Sono', 'Good sleep helps your brain.',
        'Um bom sono ajuda seu cérebro.'),
    _p('Pain', 'PÊIN', 'Dor', 'I have a pain in my back.',
        'Eu estou com uma dor nas costas.'),
    _p('Hospital', 'HÓS-pi-tâl', 'Hospital', 'The hospital is open all night.',
        'O hospital fica aberto a noite toda.'),
  ],
  'home': [
    _p('Kitchen', 'KI-tchân', 'Cozinha', 'She is in the kitchen.',
        'Ela está na cozinha.'),
    _p('Bedroom', 'BÉD-rum', 'Quarto', 'My bedroom is small.',
        'Meu quarto é pequeno.'),
    _p('Window', 'UIN-dôu', 'Janela', 'Please open the window.',
        'Por favor, abra a janela.'),
    _p('Chair', 'TCHÉR', 'Cadeira', 'This chair is comfortable.',
        'Esta cadeira é confortável.'),
    _p('Door', 'DÓR', 'Porta', 'Close the door, please.',
        'Feche a porta, por favor.'),
  ],
  'school': [
    _p('Teacher', 'TÍI-tchâr', 'Professor', 'The teacher helps the class.',
        'O professor ajuda a turma.'),
    _p('Student', 'STU-dânt', 'Estudante', 'Every student has a book.',
        'Todo estudante tem um livro.'),
    _p('Pencil', 'PÉN-sâl', 'Lápis', 'Can I use your pencil?',
        'Posso usar seu lápis?'),
    _p('Homework', 'HÔUM-uârk', 'Lição de casa', 'I finished my homework.',
        'Eu terminei minha lição de casa.'),
    _p('Classroom', 'KLÉS-rum', 'Sala de aula', 'Our classroom is quiet.',
        'Nossa sala de aula é silenciosa.'),
  ],
};
