import 'dart:io';
import 'package:projeto_mm/models/sentimento.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class AppDatabase {
  //Padrão Singleton
  static final AppDatabase _instancia = AppDatabase._internal();

  //Construtor privado
  factory AppDatabase() => _instancia;
  AppDatabase._internal();

  //Objeto do SqfLite
  Database _database;

  //get instancia
  static AppDatabase get() {
    return _instancia;
  }

  ///identificar quando a base de dados já foi inicializada
  bool databaseInicializada = false;

  ///Pega base de dados
  Future<Database> getDatabase() async {
    if (!databaseInicializada) await _criarBaseDeDados();
    return _database;
  }

  ///Cria base de dados
  Future _criarBaseDeDados() async {
    //pegar localização usando path_provider
    // print("Criou a base de dados");
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "banco_sentimentos.db");
    _database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      //Quando cria o bd, cria a tabela
      await _criarTabelaSentimento(db);
    }, onUpgrade: (Database db, int oldVersion, int newVersion) async {
      await db.execute("DROP TABLE ${Sentimento.TABELA}");
      await _criarTabelaSentimento(db);
    });
    databaseInicializada = true;
  }

  ///Criando a tabela Sentimento
  Future _criarTabelaSentimento(Database db) {
    return db.transaction((Transaction txn) async {
      txn.execute("CREATE TABLE ${Sentimento.TABELA} ("
          "${Sentimento.COLUNA_ID} INTEGER PRIMARY KEY AUTOINCREMENT,"
          "${Sentimento.COLUNA_DATA} TEXT NOT NULL UNIQUE,"
          "${Sentimento.COLUNA_SENTIMENTO} INTEGER NOT NULL,"
          "${Sentimento.COLUNA_OBSERVACAO} TEXT)");
      print('Tabela ${Sentimento.TABELA} criada com sucesso!');
    });
  }
}
