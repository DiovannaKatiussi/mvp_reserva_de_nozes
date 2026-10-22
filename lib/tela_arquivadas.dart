import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mvp_financeiro/modelos.dart';
import 'package:mvp_financeiro/paleta.dart';
import 'package:mvp_financeiro/providers.dart';
import 'package:mvp_financeiro/tela_caixinha_detalhe.dart';
import 'package:mvp_financeiro/util.dart';
import 'package:mvp_financeiro/wdg_cabecalho.dart';

/// RF-CAI-10
class TelaArquivadas extends ConsumerWidget {
  const TelaArquivadas({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumo = ref.watch(resumoProvider);
    final lista = resumo.arquivadas;
    return Scaffold(
      body: Column(
        children: [
          const CabecalhoTela(titulo: 'Caixinhas arquivadas'),
          Expanded(
            child: lista.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhuma caixinha arquivada.',
                      style: TextStyle(
                        color: AppColors.textoMarrom,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      for (final c in lista)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              title: Text(
                                c.nome,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textoMarrom,
                                ),
                              ),
                              subtitle: Text(
                                '${c.status == StatusCaixinha.concluida ? 'Concluída' : 'Desistida'} • ${formatarReais(resumo.saldoDe(c.id))}',
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      TelaCaixinhaDetalhe(caixinhaId: c.id),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
