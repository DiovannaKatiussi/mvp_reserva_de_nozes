import 'package:flutter/material.dart';
import 'package:mvp_financeiro/modelos.dart';
import 'package:mvp_financeiro/paleta.dart';
import 'package:mvp_financeiro/util.dart';
import 'package:mvp_financeiro/wdg_campo.dart';

class CampoSelecao<T> extends StatelessWidget {
  final String rotulo;
  final T? valor;
  final List<T> opcoes;
  final String Function(T) texto;
  final ValueChanged<T> onChanged;
  final String? erro;

  const CampoSelecao({
    super.key,
    required this.rotulo,
    required this.valor,
    required this.opcoes,
    required this.texto,
    required this.onChanged,
    this.erro,
  });

  Future<void> _abrir(BuildContext context) async {
    final escolhido = await showModalBottomSheet<T>(
      context: context,
      backgroundColor: AppColors.primaryBG,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                rotulo,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textoMarrom,
                ),
              ),
            ),
            for (final o in opcoes)
              ListTile(
                title: Text(texto(o)),
                trailing: o == valor
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.of(ctx).pop(o),
              ),
          ],
        ),
      ),
    );
    if (escolhido != null) onChanged(escolhido);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _abrir(context),
      child: InputDecorator(
        isEmpty: valor == null,
        decoration: decoracaoCampo(
          rotulo,
          sufixo: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.textoMarrom,
          ),
        ).copyWith(errorText: erro),
        child: Text(
          valor == null ? '' : texto(valor as T),
          style: const TextStyle(fontSize: 16, color: AppColors.primaryText),
        ),
      ),
    );
  }
}

class CampoData extends StatelessWidget {
  final DateTime? data;
  final String rotulo;
  final ValueChanged<DateTime> onChanged;
  final DateTime primeira;
  final DateTime ultima;
  final String? erro;

  const CampoData({
    super.key,
    required this.data,
    required this.onChanged,
    required this.primeira,
    required this.ultima,
    this.rotulo = 'Data',
    this.erro,
  });

  Future<void> _abrir(BuildContext context) async {
    var inicial = data ?? hoje();
    if (inicial.isBefore(primeira)) inicial = primeira;
    if (inicial.isAfter(ultima)) inicial = ultima;
    final r = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: primeira,
      lastDate: ultima,
    );
    if (r != null) onChanged(DateTime(r.year, r.month, r.day));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => _abrir(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month,
                  size: 32,
                  color: AppColors.textoMarrom,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    data == null
                        ? 'Selecionar ${rotulo.toLowerCase()}'
                        : '$rotulo: ${formatarData(data!)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textoMarrom,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (erro != null)
          Text(
            erro!,
            style: const TextStyle(color: AppColors.perigo, fontSize: 12),
          ),
      ],
    );
  }
}

Future<Caixinha?> escolherCaixinha(
  BuildContext context, {
  required String titulo,
  required List<Caixinha> opcoes,
}) {
  return showModalBottomSheet<Caixinha>(
    context: context,
    backgroundColor: AppColors.primaryBG,
    builder: (ctx) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              titulo,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textoMarrom,
              ),
            ),
          ),
          for (final c in opcoes)
            ListTile(
              title: Text(c.nome),
              onTap: () => Navigator.of(ctx).pop(c),
            ),
        ],
      ),
    ),
  );
}
