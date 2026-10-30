import 'package:flutter/material.dart';
import 'package:mvp_financeiro/paleta.dart';

class CabecalhoTela extends StatelessWidget {
  final String titulo;
  final bool mostrarVoltar;
  final List<Widget> acoes;

  const CabecalhoTela({
    super.key,
    required this.titulo,
    this.mostrarVoltar = true,
    this.acoes = const [],
  });

  @override
  Widget build(BuildContext context) {
    final topo = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: EdgeInsets.fromLTRB(mostrarVoltar ? 8 : 24, topo + 12, 8, 16),
      child: Row(
        children: [
          if (mostrarVoltar)
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          if (mostrarVoltar) const SizedBox(width: 4),
          Expanded(
            child: Text(
              titulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.primaryBG,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ...acoes,
        ],
      ),
    );
  }
}
