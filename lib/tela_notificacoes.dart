import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mvp_financeiro/modelos.dart';
import 'package:mvp_financeiro/paleta.dart';
import 'package:mvp_financeiro/providers.dart';
import 'package:mvp_financeiro/wdg_cabecalho.dart';

/// RF-CAI-12
class TelaNotificacoes extends ConsumerWidget {
  const TelaNotificacoes({super.key});

  IconData _icone(TipoAlerta t) {
    switch (t) {
      case TipoAlerta.inatividade:
        return Icons.hourglass_empty;
      case TipoAlerta.quaseConcluida:
        return Icons.emoji_events_outlined;
      case TipoAlerta.prazo:
        return Icons.alarm;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertas = gerarAlertas(ref.watch(resumoProvider));
    return Scaffold(
      body: Column(
        children: [
          const CabecalhoTela(titulo: 'Notificações'),
          Expanded(
            child: alertas.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'Tudo em dia por aqui!\nNenhum alerta no momento.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          color: AppColors.textoMarrom,
                        ),
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      for (final a in alertas)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              leading: Icon(
                                _icone(a.tipo),
                                color: AppColors.primary,
                              ),
                              title: Text(
                                a.texto,
                                style: const TextStyle(
                                  color: AppColors.textoMarrom,
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
