import 'package:flutter/material.dart';
import 'package:por_extenso/service/invertexto_service.dart';

class ValidarCpfPage extends StatefulWidget {
  const ValidarCpfPage({super.key});

  @override
  State<ValidarCpfPage> createState() => _ValidarCpfPageState();
}

class _ValidarCpfPageState extends State<ValidarCpfPage> {
  String? campo;
  String? resultado;
  final apiService = InvertextoService();

  final List<String> tipos = ['cpf', 'cnpj'];
  String? tipoSelecionado = 'cpf';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/imgs/invertexto.png',
              fit: BoxFit.contain,
              height: 40,
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            DropdownButtonFormField<String>(
              value: tipoSelecionado,
              decoration: InputDecoration(
                labelText: 'Selecione o tipo',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
              ),
              dropdownColor: Colors.black,
              style: TextStyle(color: Colors.white, fontSize: 18),
              items: tipos.map((String tipo) {
                return DropdownMenuItem<String>(
                  value: tipo,
                  child: Text(tipo, style: TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  tipoSelecionado = newValue;
                });
              },
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'Digite um CPF ou CNPJ',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.white, fontSize: 18),
              onSubmitted: (value) {
                setState(() {
                  campo = value;
                });
              },
            ),
            Expanded(
              child: (campo == null || campo!.isEmpty)
                  ? Center(
                      child: Text(
                        'Digite um CPF ou CNPJ para validar.',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : FutureBuilder(
                      future: apiService.validarCPF(campo, tipoSelecionado),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return Container(
                              width: 200,
                              height: 200,
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                strokeWidth: 5.0,
                              ),
                            );
                          default:
                            if (snapshot.hasError) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Erro: ${snapshot.error}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              });
                              return Center(
                                child: Card(
                                  color: Colors.red.shade900,
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.error_outline,
                                              color: Colors.white,
                                              size: 32,
                                            ),
                                            SizedBox(width: 12),
                                            Flexible(
                                              child: Text(
                                                'Ocorreu um erro na validação:\n${snapshot.error}',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                                textAlign: TextAlign.left,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          onPressed: () {
                                            setState(() {});
                                          },
                                          child: Text('Tentar novamente'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            } else if (snapshot.hasData) {
                              return exibeResultado(context, snapshot);
                            } else {
                              return Container();
                            }
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
  Widget exibeResultado(BuildContext context, AsyncSnapshot snapshot) {
    return Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: Text(
        snapshot.data["valid"] == true ? "Válido!" : "Inválido!",
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }
}
