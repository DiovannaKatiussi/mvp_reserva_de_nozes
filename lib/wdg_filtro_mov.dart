import 'package:flutter/material.dart';
import 'package:mvp_financeiro/modelos.dart';
import 'package:mvp_financeiro/paleta.dart';
import 'package:mvp_financeiro/util.dart';
import 'package:mvp_financeiro/wdg_selecao.dart';

/// Filtros de histórico (RF-FIN-07 e RF-FIN-08.1).
class FiltroMov {
  final DateTime? inicio;
  final DateTime? fim;
  final TipoMov? tipo;
  final String? categoria; // origem (aporte) ou motivo (retirada)

  const FiltroMov({this.inicio, this.fim, this.tipo, this.categoria});

  bool get vazio =>
      inicio == null && fim == null && tipo == null && categoria == null;
}

List<Movimentacao> aplicarFiltro(List<Movimentacao> lista, FiltroMov f) {
  final r = lista.where((m) {
    if (f.inicio != null && m.data.isBefore(f.inicio!)) return false;
    if (f.fim != null && m.data.isAfter(f.fim!)) return false;
    if (f.tipo != null && m.tipo != f.tipo) return false;
    if (f.categoria != null && m.categoria != f.categoria) return false;
    return true;
  }).toList();
  r.sort((a, b) {
    final d = b.data.compareTo(a.data);
    return d != 0 ? d : b.criadoEm.compareTo(a.criadoEm);
  });
  return r;
}

class FiltroMovWidget extends StatelessWidget {
  final FiltroMov filtro;
  final ValueChanged<FiltroMov> onChanged;

  const FiltroMovWidget({
    super.key,
    required this.filtro,
    required this.onChanged,
  });

  Future<void> _escolherPeriodo(BuildContext context) async {
    final r = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: filtro.inicio != null && filtro.fim != null
          ? DateTimeRange(start: filtro.inicio!, end: filtro.fim!)
          : null,
    );
    if (r != null) {
      onChanged(
        FiltroMov(
          inicio: DateTime(r.start.year, r.start.month, r.start.day),
          fim: DateTime(r.end.year, r.end.month, r.end.day),
          tipo: filtro.tipo,
          categoria: filtro.categoria,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final periodo = (filtro.inicio != null && filtro.fim != null)
        ? '${formatarData(filtro.inicio!)} a ${formatarData(filtro.fim!)}'
        : 'Todo o período';
    final indiceTipo = filtro.tipo == null
        ? 0
        : (filtro.tipo == TipoMov.aporte ? 1 : 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _escolherPeriodo(context),
                icon: const Icon(Icons.date_range, color: AppColors.primary),
                label: Text(
                  periodo,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textoMarrom),
                ),
              ),
            ),
            if (!filtro.vazio)
              TextButton(
                onPressed: () => onChanged(const FiltroMov()),
                child: const Text('Limpar'),
              ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<int>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment<int>(value: 0, label: Text('Todos')),
              ButtonSegment<int>(value: 1, label: Text('Aportes')),
              ButtonSegment<int>(value: 2, label: Text('Retiradas')),
            ],
            selected: {indiceTipo},
            onSelectionChanged: (s) {
              final i = s.first;
              onChanged(
                FiltroMov(
                  inicio: filtro.inicio,
                  fim: filtro.fim,
                  tipo: i == 0
                      ? null
                      : (i == 1 ? TipoMov.aporte : TipoMov.retirada),
                ),
              );
            },
          ),
        ),
        if (filtro.tipo != null) ...[
          const SizedBox(height: 12),
          CampoSelecao<String>(
            rotulo: filtro.tipo == TipoMov.aporte ? 'Origem' : 'Motivo',
            valor: filtro.categoria ?? 'Todas',
            opcoes: [
              'Todas',
              ...(filtro.tipo == TipoMov.aporte
                  ? origensAporte
                  : motivosRetirada),
            ],
            texto: (s) => s,
            onChanged: (v) => onChanged(
              FiltroMov(
                inicio: filtro.inicio,
                fim: filtro.fim,
                tipo: filtro.tipo,
                categoria: v == 'Todas' ? null : v,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class ItemMovimentacao extends StatelessWidget {
  final Movimentacao mov;
  final String? nomeCaixinha;
  final VoidCallback onTap;

  const ItemMovimentacao({
    super.key,
    required this.mov,
    required this.onTap,
    this.nomeCaixinha,
  });

  @override
  Widget build(BuildContext context) {
    final aporte = mov.tipo == TipoMov.aporte;
    final cor = aporte ? AppColors.sucesso : AppColors.perigo;
    final detalhes = [
      ?nomeCaixinha,
      mov.categoria,
      formatarData(mov.data),
    ].join(' • ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  aporte ? Icons.arrow_upward : Icons.arrow_downward,
                  color: cor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mov.nome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textoMarrom,
                        ),
                      ),
                      Text(
                        detalhes,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textoMarrom,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${aporte ? '+' : '-'} ${formatarReais(mov.valor)}',
                  style: TextStyle(color: cor, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
