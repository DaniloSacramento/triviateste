import 'package:acessonovo/app/const/const.dart';
import 'package:acessonovo/app/models/user_promote.dart';
import 'package:acessonovo/app/pages/home/home_page.dart';
import 'package:acessonovo/app/services/termo_aceite_service.dart';
import 'package:acessonovo/app/widget/app_color.dart';
import 'package:acessonovo/app/widget/tringulo_pointer.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TermoPage extends StatefulWidget {
  @override
  _TermoPageState createState() => _TermoPageState();
}

class _TermoPageState extends State<TermoPage> {
  Map<String, dynamic> responseData = {};

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final result = sharedPreferences.getString('data');
    final user = UserPromote.fromMap(jsonDecode(result!)['data']);
    final response = await http.post(
      Uri.parse(ConstsApi.termoPromotor),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'authorization': ConstsApi.basicAuth,
      },
      body: jsonEncode(
        <String, String>{
          'email': user.email,
        },
      ),
    );

    if (response.statusCode == 200) {
      final utf8decoder = Utf8Decoder();
      final data = jsonDecode(utf8decoder.convert(response.bodyBytes));
      setState(() {
        responseData = data['data'];
      });
    } else {
      print('Erro');
    }
  }

  Future<void> initializeSharedPreferences() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool('termosAceitos', false); // Inicialmente, os termos não foram aceitos
  }

  void checkTermsAccepted() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final termosAceitos = sharedPreferences.getBool('termosAceitos') ?? false;
    if (termosAceitos) {
      // ignore: use_build_context_synchronously
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(
              initialHomePage: InitialHomePage.escala,
            ),
          ),
          (r) => false);
    }
  }

  void onTermsAccepted() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool('termosAceitos', true);
    // ignore: use_build_context_synchronously
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(
            initialHomePage: InitialHomePage.escala,
          ),
        ),
        (r) => false);
  }

  Future<void> _checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Sem conexão com a internet'),
            content: Text('Verifique sua conexão com a internet e tente novamente.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkBlueColor,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: CustomPaint(
        painter: TrianguloPainter(),
        child: Center(
          child: responseData.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: screenHeight * 0.02,
                      ),
                      Text(
                        'TERMO DE\nRESPONSABILIDADE',
                        style: GoogleFonts.dosis(
                          textStyle: TextStyle(
                            fontSize: 26,
                            color: darkBlueColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        textAlign: TextAlign.start,
                      ),
                      Text('Atualizado em ${DateFormat('dd/MM/yyyy').format(DateTime.parse(responseData['dtReferencia']))}',
                          style: GoogleFonts.dosis(
                            textStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                      Text(
                        'Versão: ${responseData['versao']}',
                        style: GoogleFonts.dosis(
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    
                      SizedBox(
                        height: screenHeight * 0.55,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Html(
                                data: responseData['conteudo'],
                                style: {
                                  'body': Style(fontSize: FontSize(15.0), fontFamily: 'dosis'),
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                     
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: yellowColor,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                          onPressed: isLoading
                              ? null
                              : () {
                                  _checkInternetConnection();
                                  setState(() {
                                    isLoading = true;
                                  });

                                  TermoAceitePromotor().termoAceiteService();
                                  onTermsAccepted();
                                  setState(() {
                                    isLoading = true;
                                  });
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const HomePage(
                                          initialHomePage: InitialHomePage.escala,
                                        ),
                                      ),
                                      (r) => false);
                                },
                          child: isLoading
                              ? const CircularProgressIndicator()
                              : Text(
                                  'Aceitar termos',
                                  style: GoogleFonts.dosis(
                                    textStyle: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                        ),
                      )
                    ],
                  ),
                )
              : const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
