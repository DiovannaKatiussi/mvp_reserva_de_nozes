import 'package:flutter/material.dart';
import 'package:mvp_financeiro/modelos.dart';
import 'package:mvp_financeiro/paleta.dart';
import 'package:mvp_financeiro/util.dart';
import 'package:mvp_financeiro/wdg_barra_nozes.dart';

Color corDaFaixa(FaixaPrazo f) {
  switch (f) {
    case FaixaPrazo.urgente:
      return AppColors.perigo;
    case FaixaPrazo.atencao:
      return AppColors.atencao;
    case FaixaPrazo.tranquilo:
      return AppColors.sucesso;
  }
}

String rotuloFaixa(FaixaPrazo f) {
  switch (f) {
    case FaixaPrazo.urgente:
      return 'Urgente';
    case FaixaPrazo.atencao:
      return 'Atenção';
    case FaixaPrazo.tranquilo:
      return 'Tranquilo';
  }
}

String textoPrazo(DateTime limite) {
  final d = diasAte(limite);
  if (d < 0) return 'Prazo vencido há ${-d} dia(s)';
  return '${rotuloFaixa(faixaDoPrazo(limite))} • $d dia(s)';
}

class EtiquetaPequena extends StatelessWidget {
  final String texto;
  final Color cor;
  const EtiquetaPequena(this.texto, {super.key, this.cor = AppColors.secondary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(20)),
      child: Text(
        texto,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class CaixinhaCard extends StatelessWidget {
  final Caixinha caixinha;
  final Resumo resumo;
  final VoidCallback onTap;

  const CaixinhaCard({
    super.key,
    required this.caixinha,
    required this.resumo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = caixinha;
    final saldo = resumo.saldoDe(c.id);
    final p = resumo.progressoDe(c);
    final faixa = faixaDoPrazo(c.dataLimite);
    final cor = corDaFaixa(faixa);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        elevation: 2,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        c.nome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textoMarrom,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (c.reserva)
                      const EtiquetaPequena('Reserva', cor: AppColors.alternative)
                    else
                      EtiquetaPequena('Prioridade ${nomesPrioridade[c.prioridade.clamp(0, 2).toInt()]}'),
                  ],
                ),
                const SizedBox(height: 12),
                BarraNozes(progresso: p),
                const SizedBox(height: 10),
                Text(
                  '${formatarReais(saldo)} de ${formatarReais(c.valorAlvo)} (${formatarPercentual(p)})',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textoMarrom,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        textoPrazo(c.dataLimite),
                        style: TextStyle(color: cor, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Aportado no mês: ${formatarReais(resumo.aportadoNoMes(c.id))}',
                  style: const TextStyle(fontSize: 13, color: AppColors.textoMarrom),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
