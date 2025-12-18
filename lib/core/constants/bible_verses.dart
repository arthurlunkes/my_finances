class BibleVerse {
  final String reference;
  final String text;
  final String topic;

  const BibleVerse({
    required this.reference,
    required this.text,
    required this.topic,
  });
}

class BibleVerses {
  static const List<BibleVerse> verses = [
    // Dízimo
    BibleVerse(
      reference: 'Malaquias 3:10',
      text:
          'Trazei todos os dízimos à casa do tesouro, para que haja mantimento na minha casa, e depois fazei prova de mim, diz o Senhor dos Exércitos, se eu não vos abrir as janelas do céu e não derramar sobre vós uma bênção tal, que dela vos advenha a maior abastança.',
      topic: 'tithe',
    ),
    BibleVerse(
      reference: 'Provérbios 3:9-10',
      text:
          'Honra ao Senhor com os teus bens e com a primeira parte de todos os teus rendimentos; e se encherão os teus celeiros, e transbordarão de vinho os teus lagares.',
      topic: 'tithe',
    ),

    // Generosidade
    BibleVerse(
      reference: '2 Coríntios 9:7',
      text:
          'Cada um contribua segundo propôs no seu coração, não com tristeza ou por necessidade; porque Deus ama ao que dá com alegria.',
      topic: 'generosity',
    ),
    BibleVerse(
      reference: 'Provérbios 11:25',
      text:
          'A alma generosa prosperará, e aquele que atende também será atendido.',
      topic: 'generosity',
    ),
    BibleVerse(
      reference: 'Lucas 6:38',
      text:
          'Dai, e ser-vos-á dado; boa medida, recalcada, sacudida e transbordando vos deitarão no vosso regaço; porque com a mesma medida com que medirdes também vos medirão de novo.',
      topic: 'generosity',
    ),

    // Mordomia
    BibleVerse(
      reference: 'Lucas 16:10',
      text:
          'Quem é fiel no pouco também é fiel no muito; e quem é injusto no pouco também é injusto no muito.',
      topic: 'stewardship',
    ),
    BibleVerse(
      reference: '1 Coríntios 4:2',
      text:
          'Além disso, requer-se dos despenseiros que cada um seja encontrado fiel.',
      topic: 'stewardship',
    ),

    // Provisão
    BibleVerse(
      reference: 'Filipenses 4:19',
      text:
          'O meu Deus, segundo as suas riquezas, suprirá todas as vossas necessidades em glória, por Cristo Jesus.',
      topic: 'provision',
    ),
    BibleVerse(
      reference: 'Mateus 6:33',
      text:
          'Mas buscai primeiro o Reino de Deus, e a sua justiça, e todas essas coisas vos serão acrescentadas.',
      topic: 'provision',
    ),

    // Sabedoria Financeira
    BibleVerse(
      reference: 'Provérbios 21:5',
      text:
          'Os planos do diligente certamente dão lucro, mas a pressa excessiva leva à pobreza.',
      topic: 'wisdom',
    ),
    BibleVerse(
      reference: 'Provérbios 22:7',
      text:
          'O rico domina sobre os pobres, e o que toma emprestado é servo do que empresta.',
      topic: 'wisdom',
    ),
    BibleVerse(
      reference: 'Provérbios 13:11',
      text:
          'A riqueza de procedência vã diminuirá, mas quem a ajunta pelo trabalho a aumentará.',
      topic: 'wisdom',
    ),

    // Contentamento
    BibleVerse(
      reference: '1 Timóteo 6:6-8',
      text:
          'Mas grande ganho é a piedade com contentamento. Porque nada trouxemos para este mundo, e manifesto é que nada podemos levar dele. Tendo, porém, sustento e com que nos cobrirmos, estejamos com isso contentes.',
      topic: 'contentment',
    ),
    BibleVerse(
      reference: 'Hebreus 13:5',
      text:
          'Sejam vossos costumes sem avareza, contentando-vos com o que tendes; porque ele disse: Não te deixarei, nem te desampararei.',
      topic: 'contentment',
    ),
  ];

  static BibleVerse getRandomVerse() {
    final random = (DateTime.now().millisecondsSinceEpoch % verses.length);
    return verses[random];
  }

  static List<BibleVerse> getVersesByTopic(String topic) {
    return verses.where((verse) => verse.topic == topic).toList();
  }

  static BibleVerse getVerseOfTheDay() {
    final dayOfYear = DateTime.now()
        .difference(DateTime(DateTime.now().year, 1, 1))
        .inDays;
    return verses[dayOfYear % verses.length];
  }
}
