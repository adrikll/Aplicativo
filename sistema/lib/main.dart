import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pessoas',
      home: PessoaPage(),
    );
  }
}

class PessoaPage extends StatefulWidget {
  @override
  _PessoaPageState createState() => _PessoaPageState();
}

class _PessoaPageState extends State<PessoaPage> {
  Database? db;
  List<Map<String, dynamic>> pessoas = [];

  @override
  void initState() {
    super.initState();
    initDB();
  }

  // Função para inicializar o banco de dados
  Future<void> initDB() async {
    // Diretório de onde o banco de dados vai ser copiado
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'pessoa.db');

    // Verifica se o banco de dados já existe, se não, copia da pasta assets
    if (!File(path).existsSync()) {
      ByteData data = await rootBundle.load('assets/pessoa.db');
      List<int> bytes = data.buffer.asUint8List();
      await File(path).writeAsBytes(bytes, flush: true);
    }

    // Abre o banco de dados
    db = await openDatabase(path, readOnly: true);

    // Consulta a tabela PESSOA
    List<Map<String, dynamic>> result = await db!.query('PESSOA');
    setState(() {
      pessoas = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pessoas')),
      body: pessoas.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: pessoas.length,
        itemBuilder: (context, index) {
          final pessoa = pessoas[index];
          return ListTile(
            title: Text(pessoa['PES_NOM'] ?? 'Sem nome'),
            subtitle: Text("PES_RG: ${pessoa['PES_RG']}"),
          );
        },
      ),
    );
  }
}
