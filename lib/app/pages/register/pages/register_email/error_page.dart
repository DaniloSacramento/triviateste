// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:acessonovo/app/pages/register/pages/register_data/register_page_data.dart';
import 'package:acessonovo/app/services/validar_email_service.dart';
import 'package:acessonovo/app/widget/app_color.dart';
import 'package:acessonovo/app/widget/tringulo_pointer.dart';
import 'package:acessonovo/flavors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ErrorPageEmail extends StatefulWidget {
  final Map<String, dynamic> qrCodeConsulta;
  final String userEmail;
  const ErrorPageEmail({
    Key? key,
    required this.qrCodeConsulta,
    required this.userEmail,
  }) : super(key: key);

  @override
  State<ErrorPageEmail> createState() => _ErrorPageEmailState();
}

class _ErrorPageEmailState extends State<ErrorPageEmail> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final double buttonWidth = MediaQuery.of(context).size.width * 0.95;
    final double buttonHeight = MediaQuery.of(context).size.height * 0.07;
    double telaHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkBlueColor,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
     title: Image.asset(
            F.imageComLogoBranca,
            height: 100,
            width: 250,
          ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        child: CustomPaint(
          painter: TrianguloPainter(),
          child: Column(
            children: [
              SizedBox(
                height: telaHeight * 0.4,
                width: 950,
                child: Image.asset('assets/Captura de tela 2023-09-19 195450.png'),
              ),
              SizedBox(
                height: telaHeight * 0.07,
              ),
              Center(
                child: Text(
                  'Algo nao deu certo...',
                  style: GoogleFonts.dosis(
                    textStyle: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: darkBlueColor,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: telaHeight * 0.02,
              ),
              Text(
                'Acesse sua Caixa de E-mail e clique no \nlink para concluir a verificacao do seu \n E-mail',
                style: GoogleFonts.dosis(
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: telaHeight * 0.1,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10),
                child: SizedBox(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: yellowColor,
                      minimumSize: const Size(
                        double.infinity,
                        50,
                      ),
                    ),
                    onPressed: isLoading
                        ? null
                        : () async {
                            setState(() {
                              isLoading = true;
                            });
                            final success = await VerificarEmailService().verificarEmail(
                              email: widget.userEmail,
                            );
                            setState(() {
                              isLoading = false;
                            });
                            if (success) {
                              // ignore: use_build_context_synchronously
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RegisterData(
                                    userEmail: widget.userEmail,
                                    qrCodeConsulta: widget.qrCodeConsulta,
                                  ),
                                ),
                              );
                            }
                          },
                    child: isLoading
                        ? const CircularProgressIndicator() // Mostrar indicador de carregamento
                        : Text(
                            "Continuar",
                            style: GoogleFonts.dosis(
                              textStyle: const TextStyle(
                                fontSize: 17,
                              ),
                            ),
                          ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
