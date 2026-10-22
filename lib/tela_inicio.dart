import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mvp_financeiro/modelos.dart';
import 'package:mvp_financeiro/paleta.dart';
import 'package:mvp_financeiro/providers.dart';
import 'package:mvp_financeiro/tela_arquivadas.dart';
import 'package:mvp_financeiro/tela_caixinha_detalhe.dart';
import 'package:mvp_financeiro/tela_caixinha_form.dart';
import 'package:mvp_financeiro/tela_movimentacao_form.dart';
import 'package:mvp_financeiro/util.dart';
import 'package:mvp_financeiro/wdg_botao.dart';
import 'package:mvp_financeiro/wdg_cabecalho_inicio.dart';
import 'package:mvp_financeiro/wdg_caixinha_card.dart';

class TelaInicio extends ConsumerWidget {
  const TelaInicio({super.key});

  void _abrir(BuildContext context, Widget tela) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => tela));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumo = ref.watch(resumoProvider);
    final usuario = dadosDe(ref.watch(usuarioProvider));
    final carregando = ref.watch(caixinhasProvider).isLoading;
    final ativas = resumo.ativas;

    return Column(
      children: [
        CabecalhoInicio(
          nome: usuario?.nome ?? '',
          avatar: usuario?.avatar ?? 0,
          saldo: resumo.saldoAtual,
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: BotaoPrincipal(
                      texto: '+ Aporte',
                      onPressed: ativas.isEmpty
                          ? null
                          : () => _abrir(
                              context,
                              const TelaMovimentacaoForm(tipo: TipoMov.aporte),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BotaoPrincipal(
                      texto: '- Retirada',
                      cor: AppColors.botaoClaro,
                      corTexto: Colors.black,
                      onPressed: ativas.isEmpty
                          ? null
                          : () => _abrir(
                              context,
                              const TelaMovimentacaoForm(
                                tipo: TipoMov.retirada,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Minhas caixinhas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textoMarrom,
                      ),
                    ),
                  ),
                  if (resumo.arquivadas.isNotEmpty)
                    TextButton(
                      onPressed: () => _abrir(context, const TelaArquivadas()),
                      child: const Text('Arquivadas'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (carregando && ativas.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              for (final c in ativas)
                CaixinhaCard(
                  caixinha: c,
                  resumo: resumo,
                  onTap: () =>
                      _abrir(context, TelaCaixinhaDetalhe(caixinhaId: c.id)),
                ),
              const SizedBox(height: 4),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  // RF-CAI-04.1 e RN-CAI-03
                  if (resumo.metasAtivas >= limiteMetasAtivas) {
                    mostrarMensagem(
                      context,
                      'Limite atingido: você já tem $limiteMetasAtivas caixinhas de meta ativas.',
                    );
                    return;
                  }
                  _abrir(context, const TelaCaixinhaForm());
                },
                icon: const Icon(Icons.add, color: AppColors.primary),
                label: const Text(
                  'Nova caixinha',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
