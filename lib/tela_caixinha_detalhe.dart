import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mvp_financeiro/modelos.dart';
import 'package:mvp_financeiro/paleta.dart';
import 'package:mvp_financeiro/providers.dart';
import 'package:mvp_financeiro/tela_caixinha_form.dart';
import 'package:mvp_financeiro/tela_movimentacao_form.dart';
import 'package:mvp_financeiro/util.dart';
import 'package:mvp_financeiro/wdg_barra_nozes.dart';
import 'package:mvp_financeiro/wdg_botao.dart';
import 'package:mvp_financeiro/wdg_cabecalho.dart';
import 'package:mvp_financeiro/wdg_caixinha_card.dart';
import 'package:mvp_financeiro/wdg_filtro_mov.dart';
import 'package:mvp_financeiro/wdg_selecao.dart';

/// RF-CAI-11 e RF-FIN-07
class TelaCaixinhaDetalhe extends ConsumerStatefulWidget {
  final String caixinhaId;
  const TelaCaixinhaDetalhe({super.key, required this.caixinhaId});

  @override
  ConsumerState<TelaCaixinhaDetalhe> createState() =>
      _TelaCaixinhaDetalheState();
}

class _TelaCaixinhaDetalheState extends ConsumerState<TelaCaixinhaDetalhe> {
  FiltroMov _filtro = const FiltroMov();

  void _abrir(Widget tela) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => tela));
  }

  Future<void> _concluir(Caixinha c) async {
    final ok = await confirmarDialogo(
      context,
      titulo: 'Marcar como concluída?',
      mensagem: 'A caixinha vai para as arquivadas. O valor acumulado continua registrado nela, mas deixa de compor o saldo atual.',
      confirmar: 'Concluir',
    );
    if (!ok || !mounted) return;
    final navigator = Navigator.of(context);
    await ref.read(repositorioProvider).concluirCaixinha(c.id);
    navigator.pop();
  }

  Future<void> _desistir(Caixinha c) async {
    final resumo = ref.read(resumoProvider);
    final saldo = resumo.saldoDe(c.id);
    final outras = resumo.ativas.where((x) => x.id != c.id).toList();
    final repo = ref.read(repositorioProvider);

    if (saldo <= 0.004) {
      final ok = await confirmarDialogo(
        context,
        titulo: 'Desistir da meta?',
        mensagem: 'A caixinha "${c.nome}" será movida para as arquivadas.',
        confirmar: 'Desistir',
      );
      if (!ok || !mounted) return;
      final navigator = Navigator.of(context);
      await repo.desistirDaCaixinha(c, 0);
      navigator.pop();
      return;
    }

    final escolha = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Desistir da meta'),
        content: Text(
          'Há ${formatarReais(saldo)} acumulados em "${c.nome}". O que deseja fazer com esse valor?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('retirar'),
            child: const Text('Retirar'),
          ),
          if (outras.isNotEmpty)
            TextButton(
              onPressed: () => Navigator.of(ctx).pop('transferir'),
              child: const Text('Transferir'),
            ),
        ],
      ),
    );
    if (escolha == null || !mounted) return;

    Caixinha? destino;
    if (escolha == 'transferir') {
      destino = await escolherCaixinha(
        context,
        titulo: 'Transferir para qual caixinha?',
        opcoes: outras,
      );
      if (destino == null || !mounted) return;
    }
    final navigator = Navigator.of(context);
    await repo.desistirDaCaixinha(c, saldo, destino: destino);
    navigator.pop();
  }

  Future<void> _excluir(Caixinha c) async {
    final resumo = ref.read(resumoProvider);
    final movs = resumo.movsDe(c.id);
    final outras = resumo.ativas.where((x) => x.id != c.id).toList();
    final repo = ref.read(repositorioProvider);

    final escolha = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir caixinha'),
        content: Text(
          movs.isEmpty
              ? 'Excluir "${c.nome}"? Esta ação não pode ser desfeita.'
              : '"${c.nome}" tem ${movs.length} registro(s) de aporte/retirada. O que fazer com eles?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('tudo'),
            child: Text(movs.isEmpty ? 'Excluir' : 'Excluir tudo'),
          ),
          if (movs.isNotEmpty && outras.isNotEmpty)
            TextButton(
              onPressed: () => Navigator.of(ctx).pop('mover'),
              child: const Text('Mover registros'),
            ),
        ],
      ),
    );
    if (escolha == null || !mounted) return;

    Caixinha? destino;
    if (escolha == 'mover') {
      destino = await escolherCaixinha(
        context,
        titulo: 'Mover os registros para qual caixinha?',
        opcoes: outras,
      );
      if (destino == null || !mounted) return;
    }
    final navigator = Navigator.of(context);
    await repo.excluirCaixinha(c, movs, redirecionarPara: destino);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final resumo = ref.watch(resumoProvider);
    final c = resumo.porId(widget.caixinhaId);
    if (c == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final saldo = resumo.saldoDe(c.id);
    final p = resumo.progressoDe(c);
    final cor = corDaFaixa(faixaDoPrazo(c.dataLimite));
    final historico = aplicarFiltro(resumo.movsDe(c.id), _filtro);
    final arquivada = !c.ativa;

    return Scaffold(
      body: Column(
        children: [
          CabecalhoTela(
            titulo: c.nome,
            acoes: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (v) {
                  switch (v) {
                    case 'editar':
                      _abrir(TelaCaixinhaForm(editar: c));
                      break;
                    case 'concluir':
                      _concluir(c);
                      break;
                    case 'desistir':
                      _desistir(c);
                      break;
                    case 'excluir':
                      _excluir(c);
                      break;
                  }
                },
                itemBuilder: (_) => [
                  if (!arquivada)
                    const PopupMenuItem(value: 'editar', child: Text('Editar')),
                  if (!arquivada && !c.reserva)
                    const PopupMenuItem(
                      value: 'concluir',
                      child: Text('Marcar como concluída'),
                    ),
                  if (!arquivada && !c.reserva)
                    const PopupMenuItem(
                      value: 'desistir',
                      child: Text('Desistir da meta'),
                    ),
                  // RF-CAI-09.1: a Reserva de Emergência é obrigatória e fixa, não pode ser excluída.
                  if (!c.reserva)
                    const PopupMenuItem(
                      value: 'excluir',
                      child: Text('Excluir'),
                    ),
                ],
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (c.reserva)
                            const EtiquetaPequena(
                              'Reserva',
                              cor: AppColors.alternative,
                            )
                          else
                            EtiquetaPequena(
                              'Prioridade ${nomesPrioridade[c.prioridade.clamp(0, 2).toInt()]}',
                            ),
                          const SizedBox(width: 8),
                          if (arquivada)
                            EtiquetaPequena(
                              c.status == StatusCaixinha.concluida
                                  ? 'Concluída'
                                  : 'Desistida',
                              cor: AppColors.textoMarrom,
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        formatarReais(saldo),
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textoMarrom,
                        ),
                      ),
                      Text(
                        'de ${formatarReais(c.valorAlvo)} (${formatarPercentual(p)})',
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textoMarrom,
                        ),
                      ),
                      const SizedBox(height: 12),
                      BarraNozes(progresso: p),
                      if (p >= 1 && !arquivada) ...[
                        const SizedBox(height: 10),
                        const Text(
                          'Meta atingida! 🎉 Você já pode marcá-la como concluída.',
                          style: TextStyle(
                            color: AppColors.sucesso,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Icon(Icons.event, size: 18, color: cor),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '${formatarData(c.dataLimite)} • ${textoPrazo(c.dataLimite)}',
                              style: TextStyle(
                                color: cor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Aportado no mês: ${formatarReais(resumo.aportadoNoMes(c.id))}',
                        style: const TextStyle(color: AppColors.textoMarrom),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Maior valor já alcançado: ${formatarReais(resumo.valorMaximoDe(c))}',
                        style: const TextStyle(color: AppColors.textoMarrom),
                      ),
                    ],
                  ),
                ),
                if (!arquivada) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: BotaoPrincipal(
                          texto: '+ Aporte',
                          onPressed: () => _abrir(
                            TelaMovimentacaoForm(
                              tipo: TipoMov.aporte,
                              caixinhaId: c.id,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: BotaoPrincipal(
                          texto: '- Retirada',
                          cor: AppColors.botaoClaro,
                          corTexto: Colors.black,
                          onPressed: () => _abrir(
                            TelaMovimentacaoForm(
                              tipo: TipoMov.retirada,
                              caixinhaId: c.id,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 22),
                const Text(
                  'Histórico',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textoMarrom,
                  ),
                ),
                const SizedBox(height: 10),
                FiltroMovWidget(
                  filtro: _filtro,
                  onChanged: (f) => setState(() => _filtro = f),
                ),
                const SizedBox(height: 12),
                if (historico.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'Nenhuma movimentação encontrada.',
                        style: TextStyle(color: AppColors.textoMarrom),
                      ),
                    ),
                  ),
                for (final m in historico)
                  ItemMovimentacao(
                    mov: m,
                    onTap: () =>
                        _abrir(TelaMovimentacaoForm(tipo: m.tipo, editar: m)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
