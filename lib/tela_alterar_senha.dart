import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mvp_financeiro/paleta.dart';
import 'package:mvp_financeiro/providers.dart';
import 'package:mvp_financeiro/repositorio.dart';
import 'package:mvp_financeiro/util.dart';
import 'package:mvp_financeiro/wdg_botao.dart';
import 'package:mvp_financeiro/wdg_cabecalho.dart';
import 'package:mvp_financeiro/wdg_campo.dart';

/// RF-PER-05
class TelaAlterarSenha extends ConsumerStatefulWidget {
  const TelaAlterarSenha({super.key});

  @override
  ConsumerState<TelaAlterarSenha> createState() => _TelaAlterarSenhaState();
}

class _TelaAlterarSenhaState extends ConsumerState<TelaAlterarSenha> {
  final _chave = GlobalKey<FormState>();
  final _atual = TextEditingController();
  final _nova = TextEditingController();
  final _confirmar = TextEditingController();
  bool _carregando = false;
  String? _erro;

  @override
  void dispose() {
    _atual.dispose();
    _nova.dispose();
    _confirmar.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_chave.currentState!.validate()) return;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(repositorioProvider);
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      await repo.alterarSenha(_atual.text, _nova.text);
      messenger.showSnackBar(
        const SnackBar(content: Text('Senha alterada com sucesso!')),
      );
      navigator.pop();
      return;
    } on FirebaseAuthException catch (e) {
      _erro = e.code == 'weak-password' || e.code == 'network-request-failed'
          ? mensagemErroAuth(e)
          : 'Senha atual incorreta.';
    } catch (_) {
      _erro = 'Não foi possível alterar a senha. Tente novamente.';
    }
    if (mounted) setState(() => _carregando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CabecalhoTela(titulo: 'Alterar senha', mostrarVoltar: false),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _chave,
                child: Column(
                  children: [
                    CampoTexto(
                      controller: _atual,
                      rotulo: 'Senha atual',
                      senha: true,
                      validador: (v) =>
                          (v ?? '').isEmpty ? 'Informe a senha atual.' : null,
                    ),
                    const SizedBox(height: 14),
                    CampoTexto(
                      controller: _nova,
                      rotulo: 'Nova senha',
                      senha: true,
                      validador: validarSenha,
                    ),
                    const SizedBox(height: 14),
                    CampoTexto(
                      controller: _confirmar,
                      rotulo: 'Confirmar nova senha',
                      senha: true,
                      validador: (v) =>
                          v != _nova.text ? 'As senhas não coincidem.' : null,
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
                    const SizedBox(height: 20),
                    BotaoPrincipal(
                      texto: 'Salvar',
                      cor: AppColors.botaoClaro,
                      corTexto: Colors.black,
                      carregando: _carregando,
                      onPressed: _salvar,
                    ),
                    const SizedBox(height: 12),
                    BotaoPrincipal(
                      texto: 'Sair sem salvar',
                      cor: AppColors.perigo,
                      corTexto: AppColors.primaryBG,
                      onPressed: _carregando
                          ? null
                          : () => Navigator.of(context).pop(),
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
