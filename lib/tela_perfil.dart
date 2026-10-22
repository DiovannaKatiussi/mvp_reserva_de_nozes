import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mvp_financeiro/paleta.dart';
import 'package:mvp_financeiro/providers.dart';
import 'package:mvp_financeiro/repositorio.dart';
import 'package:mvp_financeiro/tela_alterar_senha.dart';
import 'package:mvp_financeiro/tela_editar_perfil.dart';
import 'package:mvp_financeiro/tela_notificacoes.dart';
import 'package:mvp_financeiro/tela_termos.dart';
import 'package:mvp_financeiro/wdg_avatar.dart';
import 'package:mvp_financeiro/wdg_botao.dart';

class TelaPerfil extends ConsumerStatefulWidget {
  const TelaPerfil({super.key});

  @override
  ConsumerState<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends ConsumerState<TelaPerfil> {
  bool _ocupado = false;

  void _abrir(Widget tela) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => tela));
  }

  /// RF-PER-06
  Future<void> _sair() async {
    final navigator = Navigator.of(context);
    final repo = ref.read(repositorioProvider);
    await repo.sair();
    navigator.popUntil((rota) => rota.isFirst);
  }

  /// RF-PER-07
  Future<void> _excluirConta() async {
    final senha = await showDialog<String>(
      context: context,
      builder: (_) => const _DialogExcluirConta(),
    );
    if (senha == null || !mounted) return;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(repositorioProvider);
    setState(() => _ocupado = true);
    try {
      await repo.excluirConta(senha);
      navigator.popUntil((rota) => rota.isFirst);
    } on FirebaseAuthException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(mensagemErroAuth(e))));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Não foi possível excluir a conta. Tente novamente.'),
        ),
      );
    }
    if (mounted) setState(() => _ocupado = false);
  }

  @override
  Widget build(BuildContext context) {
    final usuario = dadosDe(ref.watch(usuarioProvider));
    final topo = MediaQuery.of(context).padding.top;

    final itens = <(String, VoidCallback)>[
      ('Editar perfil', () => _abrir(const TelaEditarPerfil())),
      ('Alterar senha', () => _abrir(const TelaAlterarSenha())),
      ('Notificações', () => _abrir(const TelaNotificacoes())),
      ('Termos de uso', () => _abrir(const TelaTermos())),
      ('Excluir conta', _excluirConta),
    ];

    return Stack(
      children: [
        Column(
          children: [
            Container(
              width: double.infinity,
              color: AppColors.primary,
              padding: EdgeInsets.fromLTRB(24, topo + 24, 24, 24),
              child: Row(
                children: [
                  AvatarImagem(
                    indice: usuario?.avatar ?? 0,
                    tamanho: 92,
                    borda: true,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          usuario?.nome ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.primaryBG,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          usuario?.email ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFF1CFC4),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                children: [
                  for (final item in itens)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: Colors.white,
                        elevation: 1.5,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: _ocupado ? null : item.$2,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 24,
                            ),
                            child: Text(
                              item.$1,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textoMarrom,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Center(
                    child: SizedBox(
                      width: 170,
                      child: BotaoPrincipal(
                        texto: 'Sair',
                        cor: AppColors.perigo,
                        corTexto: AppColors.primaryBG,
                        onPressed: _ocupado ? null : _sair,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (_ocupado)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x66000000),
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}

class _DialogExcluirConta extends StatefulWidget {
  const _DialogExcluirConta();

  @override
  State<_DialogExcluirConta> createState() => _DialogExcluirContaState();
}

class _DialogExcluirContaState extends State<_DialogExcluirConta> {
  final _senha = TextEditingController();
  bool _oculto = true;

  @override
  void dispose() {
    _senha.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Excluir conta'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Esta ação é irreversível: sua conta e todos os seus dados (caixinhas, aportes e retiradas) serão apagados permanentemente.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _senha,
            obscureText: _oculto,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Digite sua senha para confirmar',
              suffixIcon: IconButton(
                icon: Icon(
                  _oculto
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () => setState(() => _oculto = !_oculto),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: _senha.text.isEmpty
              ? null
              : () => Navigator.of(context).pop(_senha.text),
          child: const Text(
            'Excluir definitivamente',
            style: TextStyle(color: AppColors.perigo),
          ),
        ),
      ],
    );
  }
}
