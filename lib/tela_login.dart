import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mvp_financeiro/paleta.dart';
import 'package:mvp_financeiro/providers.dart';
import 'package:mvp_financeiro/repositorio.dart';
import 'package:mvp_financeiro/tela_cadastro.dart';
import 'package:mvp_financeiro/tela_esqueci_senha.dart';
import 'package:mvp_financeiro/util.dart';
import 'package:mvp_financeiro/wdg_botao.dart';
import 'package:mvp_financeiro/wdg_campo.dart';
import 'package:mvp_financeiro/wdg_logo.dart';

class TelaLogin extends ConsumerStatefulWidget {
  const TelaLogin({super.key});

  @override
  ConsumerState<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends ConsumerState<TelaLogin> {
  final _chave = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  bool _carregando = false;
  String? _erro;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_chave.currentState!.validate()) return;
    final repo = ref.read(repositorioProvider);
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      await repo.entrar(_email.text, _senha.text);
      return;
    } on FirebaseAuthException catch (e) {
      _erro = mensagemErroAuth(e, login: true); // RF-PER-02.1
    } catch (_) {
      _erro = 'Não foi possível entrar. Tente novamente.';
    }
    if (mounted) setState(() => _carregando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBG,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _chave,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                  child: logoCompleta,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 20, 32, 24),
                  child: Column(
                    children: [
                      CampoTexto(
                        controller: _email,
                        rotulo: 'E-mail',
                        teclado: TextInputType.emailAddress,
                        validador: validarEmail,
                      ),
                      const SizedBox(height: 16),
                      CampoTexto(
                        controller: _senha,
                        rotulo: 'Senha',
                        senha: true,
                        validador: (v) =>
                            (v ?? '').isEmpty ? 'Informe sua senha.' : null,
                      ),
                      if (_erro != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _erro!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.perigo,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      BotaoPrincipal(
                        texto: 'Entrar',
                        carregando: _carregando,
                        onPressed: _entrar,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const TelaEsqueciSenha(),
                          ),
                        ),
                        child: const Text(
                          'Esqueceu sua senha',
                          style: TextStyle(
                            color: AppColors.link,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Novo por aqui? ',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textoMarrom,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const TelaCadastro(),
                              ),
                            ),
                            child: const Text(
                              'Cadastre-se',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
