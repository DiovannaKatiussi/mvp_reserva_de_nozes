import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mvp_financeiro/paleta.dart';

class Castanha extends StatelessWidget {
  final double altura;
  const Castanha({super.key, this.altura = 24});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/imagens/im_Castanha.png',
      height: altura,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) =>
          Icon(Icons.circle, size: altura * 0.7, color: AppColors.secondary),
    );
  }
}

/// RF-CAI-13
class BarraNozes extends StatelessWidget {
  final double progresso;
  final int total;

  const BarraNozes({super.key, required this.progresso, this.total = 10});

  @override
  Widget build(BuildContext context) {
    final p = progresso.clamp(0.0, 1.0).toDouble();
    final cheias = (p * total).floor();
    final resto = p * total - cheias;
    return LayoutBuilder(
      builder: (context, restricoes) {
        final altura = math.min(24.0, restricoes.maxWidth / total / 1.15);
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(total, (i) {
            double opacidade;
            if (i < cheias) {
              opacidade = 1;
            } else if (i == cheias && p < 1) {
              opacidade = 0.25 + 0.75 * resto;
            } else {
              opacidade = 0.25;
            }
            return Opacity(
              opacity: opacidade,
              child: Castanha(altura: altura),
            );
          }),
        );
      },
    );
  }
}
