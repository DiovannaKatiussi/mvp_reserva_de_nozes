import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mvp_financeiro/modelos.dart';
import 'package:mvp_financeiro/paleta.dart';
import 'package:mvp_financeiro/providers.dart';
import 'package:mvp_financeiro/tela_movimentacao_form.dart';
import 'package:mvp_financeiro/wdg_cabecalho.dart';
import 'package:mvp_financeiro/wdg_filtro_mov.dart';
import 'package:mvp_financeiro/wdg_grafico.dart';

/// RF-FIN-08
class TelaDashboard extends ConsumerStatefulWidget {
  const TelaDashboard({super.key});

  @override
  ConsumerState<TelaDashboard> createState() => _TelaDashboardState();
}

class _TelaDashboardState extends ConsumerState<TelaDashboard> {
  FiltroMov _filtro = const FiltroMov();

  @override
  Widget build(BuildContext context) {
    final resumo = ref.watch(resumoProvider);
    final lista = aplicarFiltro(resumo.movs, _filtro);
    final pontos = pontosSaldo(
      resumo.movs,
      inicio: _filtro.inicio,
      fim: _filtro.fim,
    );

    return Column(
      children: [
        const CabecalhoTela(titulo: 'Dashboard', mostrarVoltar: false),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Evolução do saldo',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textoMarrom,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GraficoSaldo(pontos: pontos),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FiltroMovWidget(
                filtro: _filtro,
                onChanged: (f) => setState(() => _filtro = f),
              ),
              const SizedBox(height: 16),
              Text(
                'Movimentações (${lista.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textoMarrom,
                ),
              ),
              const SizedBox(height: 8),
              if (lista.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'Nenhuma movimentação encontrada.',
                      style: TextStyle(color: AppColors.textoMarrom),
                    ),
                  ),
                ),
              for (final m in lista)
                ItemMovimentacao(
                  mov: m,
                  nomeCaixinha: resumo.porId(m.caixinhaId)?.nome,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          TelaMovimentacaoForm(tipo: m.tipo, editar: m),
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
