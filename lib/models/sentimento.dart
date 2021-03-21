class Sentimento {
  //Dados da tabela SQL
  static final TABELA = 'sentimentos';
  static final COLUNA_ID = 'id';
  static final COLUNA_DATA = 'data';
  static final COLUNA_SENTIMENTO = 'sentimento';
  static final COLUNA_OBSERVACAO = 'observacao';

  int id;
  String data;
  int sentimento;
  String observacao;

  Sentimento({this.data, this.sentimento, this.observacao, this.id});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'data': data,
      'sentimento': sentimento,
      'observacao': observacao,
    };
  }

  factory Sentimento.fromMap(Map<String, dynamic> map) {
    // print(map.toString());
    if (map == null) return null;

    return Sentimento(
      id: map['id'],
      data: map['data'],
      sentimento: map['sentimento'],
      observacao: map['observacao'],
    );
  }
}
