import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mvp_financeiro/paleta.dart';
import 'package:mvp_financeiro/providers.dart';
import 'package:mvp_financeiro/util.dart';
import 'package:mvp_financeiro/wdg_botao.dart';
import 'package:mvp_financeiro/wdg_cabecalho.dart';
import 'package:mvp_financeiro/wdg_campo.dart';

/// RF-PER-03
class TelaEsqueciSenha extends ConsumerStatefulWidget {
  const TelaEsqueciSenha({super.key});

  @override
  ConsumerState<TelaEsqueciSenha> createState() => _TelaEsqueciSenhaState();
}

class _TelaEsqueciSenhaState extends ConsumerState<TelaEsqueciSenha> {
  final _chave = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _carregando = false;
  bool _enviado = false;
  String? _erro;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_chave.currentState!.validate()) return;
    final repo = ref.read(repositorioProvider);
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      await repo.recuperarSenha(_email.text);
      _enviado = true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        _erro = 'Sem conexão com a internet. Verifique sua rede.';
      } else {
        _enviado = true;
      }
    } catch (_) {
      _erro = 'Não foi possível enviar agora. Tente novamente.';
    }
    if (mounted) setState(() => _carregando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CabecalhoTela(titulo: 'Recuperar senha'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _chave,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informe o e-mail da sua conta. Enviaremos um link para você criar uma nova senha.',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textoMarrom,
                      ),
                    ),
                    const SizedBox(height: 20),
                    CampoTexto(
                      controller: _email,
                      rotulo: 'E-mail',
                      teclado: TextInputType.emailAddress,
                      validador: validarEmail,
                    ),
                    const SizedBox(height: 16),
                    if (_enviado)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Text(
                          'Se este e-mail estiver cadastrado, você receberá um link de redefinição em instantes.',
                          style: TextStyle(
                            color: AppColors.sucesso,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    if (_erro != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          _erro!,
                          style: const TextStyle(
                            color: AppColors.perigo,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    BotaoPrincipal(
                      texto: 'Enviar link',
                      carregando: _carregando,
                      onPressed: _enviar,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
