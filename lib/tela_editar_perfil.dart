import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mvp_financeiro/paleta.dart';
import 'package:mvp_financeiro/providers.dart';
import 'package:mvp_financeiro/wdg_avatar.dart';
import 'package:mvp_financeiro/wdg_botao.dart';
import 'package:mvp_financeiro/wdg_cabecalho.dart';
import 'package:mvp_financeiro/wdg_campo.dart';

/// RF-PER-04, RN-PER-03 e RN-PER-02
class TelaEditarPerfil extends ConsumerStatefulWidget {
  const TelaEditarPerfil({super.key});

  @override
  ConsumerState<TelaEditarPerfil> createState() => _TelaEditarPerfilState();
}

class _TelaEditarPerfilState extends ConsumerState<TelaEditarPerfil> {
  final _chave = GlobalKey<FormState>();
  late final TextEditingController _nome;
  late int _avatar;
  bool _carregando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    final u = dadosDe(ref.read(usuarioProvider));
    _nome = TextEditingController(text: u?.nome ?? '');
    _avatar = u?.avatar ?? 0;
  }

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_chave.currentState!.validate()) return;
    final navigator = Navigator.of(context);
    final repo = ref.read(repositorioProvider);
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      await repo.atualizarPerfil(nome: _nome.text, avatar: _avatar);
      navigator.pop();
    } catch (_) {
      if (mounted) {
        setState(() {
          _carregando = false;
          _erro = 'Não foi possível salvar. Tente novamente.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = dadosDe(ref.watch(usuarioProvider))?.email ?? '';
    return Scaffold(
      body: Column(
        children: [
          const CabecalhoTela(titulo: 'Editar perfil', mostrarVoltar: false),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _chave,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [git status
                    const Text(
                      'Escolha seu avatar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textoMarrom,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (var i = 0; i < 3; i++)
                          GestureDetector(
                            onTap: () => setState(() => _avatar = i),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _avatar == i
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              child: AvatarImagem(indice: i, tamanho: 76),
                            ),
                          ),
                      ],
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
                    const SizedBox(height: 10),
                    Text(
                      'E-mail: $email (não pode ser alterado)',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textoMarrom,
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
