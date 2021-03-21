import 'package:flutter/material.dart';
import 'package:projeto_mm/main.dart';

class HistoricoSentimentos extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico de Sentimentos'),
      ),
      body: ListView.builder(
        //Acessa lista da classe main para pegar tamanho
        itemCount: lista.length,
        itemBuilder: (BuildContext ctxt, int index) {
          //Obtem índice do ListView, na lista para atribuir ao item atual
          final item = lista[index];
          //Gera ListTile com informações do item atual
          return ListTile(
            leading: defineIconeSentimento(item.sentimento),
            title: Text("Data: ${item.data}"),
            subtitle: Text("${item.observacao}"),
          );
        },
      ),
    );
  }
}
