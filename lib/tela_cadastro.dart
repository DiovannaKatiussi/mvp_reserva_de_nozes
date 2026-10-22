import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mvp_financeiro/paleta.dart';
import 'package:mvp_financeiro/providers.dart';
import 'package:mvp_financeiro/repositorio.dart';
import 'package:mvp_financeiro/tela_termos.dart';
import 'package:mvp_financeiro/util.dart';
import 'package:mvp_financeiro/wdg_botao.dart';
import 'package:mvp_financeiro/wdg_campo.dart';

class TelaCadastro extends ConsumerStatefulWidget {
  const TelaCadastro({super.key});

  @override
  ConsumerState<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends ConsumerState<TelaCadastro> {
  final _chave = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  final _confirmar = TextEditingController();
  bool _carregando = false;
  String? _erro;

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _senha.dispose();
    _confirmar.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!_chave.currentState!.validate()) return;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(repositorioProvider);
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      await repo.cadastrar(
        nome: _nome.text,
        email: _email.text,
        senha: _senha.text,
      );
      // RF-PER-01.4
      messenger.showSnackBar(
        const SnackBar(content: Text('Cadastro concluído com sucesso!')),
      );
      navigator.popUntil((rota) => rota.isFirst);
      return;
    } on FirebaseAuthException catch (e) {
      _erro = mensagemErroAuth(e); // RF-PER-01.2
    } catch (_) {
      _erro = 'Não foi possível concluir o cadastro. Tente novamente.';
    }
    if (mounted) setState(() => _carregando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBG,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Form(
              key: _chave,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Crie sua conta',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Preencha os campos abaixo para começar.',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textoMarrom,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CampoTexto(
                    controller: _nome,
                    rotulo: 'Nome',
                    capitalizacao: TextCapitalization.words,
                    validador: (v) => (v ?? '').trim().length < 2
                        ? 'Informe seu nome.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  CampoTexto(
                    controller: _email,
                    rotulo: 'E-mail',
                    teclado: TextInputType.emailAddress,
                    validador: validarEmail, // RF-PER-01.1
                  ),
                  const SizedBox(height: 16),
                  CampoTexto(
                    controller: _senha,
                    rotulo: 'Senha',
                    senha: true,
                    validador: validarSenha, // RN-PER-01
                  ),
                  const SizedBox(height: 16),
                  CampoTexto(
                    controller: _confirmar,
                    rotulo: 'Confirmar senha',
                    senha: true,
                    validador: (v) =>
                        v != _senha.text ? 'As senhas não coincidem.' : null,
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TelaTermos()),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'Ao tocar em Cadastrar, você concorda com os nossos Termos de Uso e Política de Privacidade.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textoMarrom,
                        ),
                      ),
                    ),
                  ),
                  if (_erro != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _erro!,
                      style: const TextStyle(
                        color: AppColors.perigo,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  BotaoPrincipal(
                    texto: 'Cadastrar',
                    carregando: _carregando,
                    onPressed: _cadastrar,
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: const Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Já tem uma conta? ',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textoMarrom,
                              ),
                            ),
                            TextSpan(
                              text: 'Entrar',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Image.asset(
                      'assets/imagens/im_Logo.png',
                      width: 240,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
