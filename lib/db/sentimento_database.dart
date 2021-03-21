import 'package:projeto_mm/db/app_database.dart';
import 'package:projeto_mm/models/sentimento.dart';
import 'package:sqflite/sqflite.dart';

class SentimentoDatabase {
  static final SentimentoDatabase _db =
      SentimentoDatabase._internal(AppDatabase.get());

  AppDatabase _appDatabase;

  //Construtor interno privado para tornar singleton
  SentimentoDatabase._internal(this._appDatabase);

  static SentimentoDatabase get() {
    return _db;
  }

  ///Lista dados da tabela sentimentos em ordem decrescente
  Future<List<Sentimento>> getSentimentos() async {
    var db = await _appDatabase.getDatabase();
    var resultado = await db
        .rawQuery('SELECT * FROM ${Sentimento.TABELA} ORDER BY(id) DESC');

    List<Sentimento> lista = List();
    for (Map<String, dynamic> item in resultado) {
      var sentimento = Sentimento.fromMap(item);
      lista.add(sentimento);
    }
    return lista;
  }

  ///Calcula a porcentagem de felicidade baseado no histórico do banco de dados
  Future<double> getPorcentagemFelicidade() async {
    var db = await _appDatabase.getDatabase();
    var resultado = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT (SUM(sentimento)*100)/(COUNT(sentimento)*5) FROM ${Sentimento.TABELA}'));
    if (resultado != null) {
      return resultado.toDouble();
    } else {
      return 0;
    }
  }

  ///Busca do banco e retorna o ID do sentimento registrado, através da data
  Future<int> getSentimentoData(String data) async {
    var db = await _appDatabase.getDatabase();
    int sentimento = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT sentimento FROM ${Sentimento.TABELA} WHERE data="${data}"'));
    return sentimento;
  }

  ///Insere informações na tabela do banco ou atualiza se já existir uma linha com a data que está registrando
  Future inserirOuAtualizar(Sentimento sentimento) async {
    //Se a data que está sendo registrada já constar no banco essa condição será verdadeira e irá atualizar o registro
    if (await getSentimentoData(sentimento.data) != null) {
      return atualizar(sentimento);
    }

    //Senão vai inserir os dados passados
    var db = await _appDatabase.getDatabase();
    return await db.transaction((Transaction txn) async {
      print("Registrando sentimento...");
      return await txn.rawInsert('INSERT INTO '
          '${Sentimento.TABELA}(${Sentimento.COLUNA_ID},${Sentimento.COLUNA_DATA},${Sentimento.COLUNA_SENTIMENTO},${Sentimento.COLUNA_OBSERVACAO})'
          ' VALUES(${sentimento.id},"${sentimento.data}", ${sentimento.sentimento}, "${sentimento.observacao}")');
    });
  }

  ///Atualiza o registro quando está tentando inserir no banco outro registro na mesma data
  Future atualizar(Sentimento sentimento) async {
    var db = await _appDatabase.getDatabase();

    return await db.transaction((Transaction txn) async {
      return await txn.rawInsert('UPDATE ${Sentimento.TABELA} '
          'SET ${Sentimento.COLUNA_SENTIMENTO} = ${sentimento.sentimento}, '
          '${Sentimento.COLUNA_OBSERVACAO} = "${sentimento.observacao}" '
          'WHERE ${Sentimento.COLUNA_DATA} = "${sentimento.data}"');
    });
  }
}
