import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';


String request = "https://api.hgbrasil.com/finance/stock_price?key=6c5f8a22";

Future<Conteudo> getData(String symbol) async {
  String upSymbol = symbol.toUpperCase();
  print(upSymbol);
  String uri = request+"&symbol="+upSymbol;
  print(uri);
  http.Response response = await http.get(Uri.parse(uri));

  if (response.statusCode == 200) {
    var json = jsonDecode(response.body);
    var conteudo = Conteudo(
      nome: json['results'][upSymbol]["name"],
      valor: json['results'][upSymbol]["price"],
      //code: json['results'][symbol]["symbol"]
    );
    return conteudo;
  } else {
    throw Exception('Falha ao carregar um post');
  }
}

class Conteudo {
  final String nome;
  final double valor;

//final String code;

  const Conteudo({
    required this.nome,
    required this.valor,
    //required this.code,
  });
}
void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(hintColor: Colors.amber, primaryColor: Colors.amber),
  ));

}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home>{


  @override
   void initState(){
     super.initState();
   }


  TextEditingController consultaController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Future<Conteudo>? _futureCont;


  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Consulta Bolsa de Valores"),
        ),
        drawer: const Drawer(),
        body:  SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextFormField(
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        labelText: "Digite o Código",
                        labelStyle: TextStyle(color: Colors.grey, fontSize: 28.7)
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.blue, fontSize: 26.3),
                    controller: consultaController,
                    validator: (value){
                      if(value!.isEmpty)
                        return "Por favor, insira o código";
                      else
                        return null;
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: ButtonTheme(
                        height: 50.0,
                        highlightColor: Colors.blue,
                        child: ElevatedButton(
                          onPressed: () {
                            if(_formKey.currentState!.validate()) {
                              setState(() {
                                 _futureCont = getData(consultaController.text);
                              });
                            }
                          },
                          child: Text(
                            "Consultar",
                            //sytle: TextStyle(color: Colors.blue, fontSize: 26.3)
                          ),
                        )),
                  ),
                    Center(
                      child: FutureBuilder<Conteudo>(
                      future: _futureCont,
                      builder: (context,snapshot){
                        if(snapshot.hasData){
                          return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  'Nome : ' + snapshot.data!.nome.toString() + '\n\nPreco : '+ snapshot.data!.valor.toString()),
                          );

                        }else if(snapshot.hasError){
                          return Text("${snapshot.error}");
                        }
                        return CircularProgressIndicator();
                      },
                    ),
                    ),
            ],
          ),
         ),
        ),

        bottomNavigationBar: BottomNavigationBar(

          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.refresh),
              label: "Limpar",

            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Configurações",
            )

          ],
        ),
      ),
    );
  }
}