import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projeto_mm/db/app_database.dart';
import 'package:projeto_mm/views/historico_sentimentos.dart';
import 'db/sentimento_database.dart';
import 'models/CircleProgress.dart';
import 'models/sentimento.dart';

///Define a porcentagem atual no nível geral de felicidade
double porcentagemAtual = 0;

///Guarda o ícone que representa o sentimento selecionado no dia atual
Icon iconeDeHoje;

///Lista de sentimentos registrados que serão resgatados do histórico no BD
List<Sentimento> lista;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Singleton utilizado para trabalhar com a tabela de sentimentos
  await AppDatabase.get().getDatabase();

  //Atribui os itens do banco na lista
  lista = await SentimentoDatabase.get().getSentimentos();

  //Pegar a porcentagem de felicidade para construir o círculo de progresso
  porcentagemAtual = await SentimentoDatabase.get().getPorcentagemFelicidade();

  //Define o ícone que representará o sentimento escolhido (ou não) hoje
  iconeDeHoje = defineIconeSentimento(await SentimentoDatabase.get()
      .getSentimentoData(DateFormat('dd/MM/yyyy').format(DateTime.now())));

  runApp(MyApp());
}

///Função para definir o ícone do sentimento escolhido no dia, a partir do ID seleciona qual o ícone correspondente.
Icon defineIconeSentimento(int idSentimento) {
  switch (idSentimento) {
    case 5:
      return Icon(Icons.sentiment_very_satisfied_outlined,
          color: Colors.green, size: 50);
      break;
    case 4:
      return Icon(Icons.sentiment_satisfied_alt_outlined,
          color: Colors.lightBlue, size: 50);
      break;
    case 3:
      return Icon(Icons.sentiment_neutral,
          color: Colors.blueAccent[700], size: 50);
      break;
    case 2:
      return Icon(Icons.sentiment_dissatisfied_sharp,
          color: Colors.orange, size: 50);
      break;
    case 1:
      return Icon(Icons.sentiment_very_dissatisfied_sharp,
          color: Colors.red, size: 50);
      break;
    default:
      return Icon(Icons.all_out, color: Colors.grey, size: 50);
  }
}

class MyApp extends StatelessWidget {
  static const String _titulo = 'Felicitômetro';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _titulo,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text(_titulo)),
        body: ListView(
          padding: const EdgeInsets.all(5),
          children: [
            SentimentoWidget(),
            //Construtor para o botão que troca para a página do histórico
            Builder(
              builder: (context) => Align(
                alignment: Alignment.topRight,
                child: FloatingActionButton(
                  child: Icon(
                    Icons.menu_book,
                    size: 40,
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        //Acessa a outra página
                        MaterialPageRoute(
                            builder: (context) => HistoricoSentimentos()));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SentimentoWidget extends StatefulWidget {
  @override
  _SentimentoWidgetState createState() => _SentimentoWidgetState();
}

class _SentimentoWidgetState extends State<SentimentoWidget>
    with SingleTickerProviderStateMixin {
  ///Controles da animação do círculo de progresso
  AnimationController progressController;
  Animation<double> animation;

  ///Variável para definir quando o sentimento foi escolhido e mudar o ícone
  int _sentimentoEscolhido = 0;

  ///Variável que salva o valor da porcentagem antes de atualizar
  double porcentagemIndicada = 0;

  ///Define o estado inicial do círculo de progresso para construí-lo
  void initState() {
    super.initState();

    progressController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 10000));

    animation = Tween<double>(begin: 0, end: porcentagemAtual)
        .animate(progressController)
          ..addListener(() {
            setState(() {});
          });

    //Inicia a progressão (animação)
    progressController.forward();
  }

  ///Caixa de entrada de Texto para descrever a observação
  Future<String> criarAlertDialog(BuildContext ctx) {
    TextEditingController controlador = TextEditingController();

    return showDialog(
      context: ctx,
      builder: (ctx) {
        return AlertDialog(
          title: Text("Descreva seus motivos para escolher esse sentimento:"),
          content: TextField(
            controller: controlador,
          ),
          actions: <Widget>[
            MaterialButton(
              elevation: 5.0,
              child: Text('Salvar'),
              onPressed: () {
                //Tirar o valor digitado fora do AlertDialog, levando para a janela de origem
                Navigator.of(context).pop(controlador.text.toString());
              },
            )
          ],
        );
      },
    );
  }

  ///Componentes da interface
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: [
        //Cabecalio
        Center(
          child: Container(
            padding: const EdgeInsets.all(30),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Text(
                          DateFormat("'Dia:' dd/MM/yyyy")
                              .format(DateTime.now()),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Container(
                        child: Text(
                          'Como se sente hoje?',
                          style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 19,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                iconeDeHoje
              ],
            ),
          ),
        ),

        //Primeira Linha sentimentos
        Row(
          //Preenche os itens no espaço da tela
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            /* 5-Radiante */
            Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //Botão clicável em formato de ícone
                  IconButton(
                      icon: Icon(
                        _sentimentoEscolhido == 5
                            ? Icons.sentiment_very_satisfied_outlined
                            : Icons.sentiment_very_satisfied,
                        color: Colors.green,
                      ),
                      //Tamanho do ícone
                      iconSize: 60,
                      //Ação quando clicar
                      onPressed: () {
                        //Chamar alertDialog e função principal
                        criarAlertDialog(context).then((onValue) {
                          _sentimentoSelecionado(5, onValue);
                        });
                      }),
                  //Texto do ícone
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      'Radiante',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /* 4-Bem */
            Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      _sentimentoEscolhido == 4
                          ? Icons.sentiment_satisfied_alt_outlined
                          : Icons.sentiment_satisfied,
                      color: Colors.lightBlue,
                    ),
                    iconSize: 60,
                    onPressed: () {
                      criarAlertDialog(context).then((onValue) {
                        _sentimentoSelecionado(4, onValue);
                      });
                    },
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      'Bem',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.lightBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /* 3-Normal */
            Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      _sentimentoEscolhido == 3
                          ? Icons.sentiment_neutral
                          : Icons.sentiment_neutral_outlined,
                      color: Colors.blueAccent[700],
                    ),
                    iconSize: 60,
                    onPressed: () {
                      criarAlertDialog(context).then((onValue) {
                        _sentimentoSelecionado(3, onValue);
                      });
                    },
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      'Normal',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.blueAccent[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        //Segunda Linha sentimentos
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            /* 2-Mal */
            Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      _sentimentoEscolhido == 2
                          ? Icons.sentiment_dissatisfied_sharp
                          : Icons.sentiment_dissatisfied,
                      color: Colors.orange,
                    ),
                    iconSize: 60,
                    onPressed: () {
                      criarAlertDialog(context).then((onValue) {
                        _sentimentoSelecionado(2, onValue);
                      });
                    },
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 6, bottom: 30),
                    child: Text(
                      'Mal',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /* 1-Muito mal */
            Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      _sentimentoEscolhido == 1
                          ? Icons.sentiment_very_dissatisfied_sharp
                          : Icons.mood_bad_sharp,
                      color: Colors.red,
                    ),
                    iconSize: 60,
                    onPressed: () {
                      criarAlertDialog(context).then((onValue) {
                        _sentimentoSelecionado(1, onValue);
                      });
                    },
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 6, bottom: 30),
                    child: Text(
                      'Muito mal',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        //Círculo de progresso (Nível geral de felicidade)
        SizedBox(
          child: Center(
            child: Column(children: [
              Padding(
                padding: EdgeInsets.only(top: 20),
              ),
              //Título
              Container(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  "Nível Geral de Felicidade",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                  ),
                ),
              ),
              //Círculo
              CustomPaint(
                foregroundPainter: CircleProgress(animation.value),
                child: Container(
                  width: 200,
                  height: 200,
                  //Exibir porcentagem atual
                  child: Center(
                    child: Text(
                      "${animation.value.toInt()}%",
                      style:
                          TextStyle(fontSize: 40, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  ///Realizar a atualização da variavel que controla os ícones (atualizando o state)
  ///e registrar o sentimento selecionado.
  void _sentimentoSelecionado(int idSentimento, String observacao) async {
    //Inserir sentimento selecionado no banco de dados
    try {
      await SentimentoDatabase.get().inserirOuAtualizar(Sentimento(
          //Pegar Hora (Apenas teste), depois tenq pegar a data
          data: DateFormat('dd/MM/yyyy').format(DateTime.now()),
          sentimento: idSentimento,
          observacao: observacao));
    } on Exception catch (e) {
      print(e);
    }

    //Salvando o valor da porcentagem antes de atualizar
    porcentagemIndicada = animation.value;

    //Atualizando porcentagem
    porcentagemAtual =
        await SentimentoDatabase.get().getPorcentagemFelicidade();

    //Verificando se a animação irá se mover para frente ou para tras
    if (porcentagemIndicada < porcentagemAtual) {
      animation =
          Tween<double>(begin: porcentagemIndicada, end: porcentagemAtual)
              .animate(progressController)
                ..addListener(() {
                  setState(() {});
                });
      progressController.forward();
    } else {
      animation =
          Tween<double>(begin: porcentagemAtual, end: porcentagemIndicada)
              .animate(progressController)
                ..addListener(() {
                  setState(() {});
                });
      progressController.reverse();
    }

    //Atualiza lista com o último registro
    lista = await SentimentoDatabase.get().getSentimentos();

    setState(() {
      //Atualiza icone no botão quando clica
      _sentimentoEscolhido = idSentimento;
      //Atualiza o ícone de hoje
      iconeDeHoje = defineIconeSentimento(idSentimento);
    });
  }
}
