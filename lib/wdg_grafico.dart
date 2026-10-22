import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mvp_financeiro/modelos.dart';
import 'package:mvp_financeiro/paleta.dart';
import 'package:mvp_financeiro/util.dart';

class GraficoSaldo extends StatelessWidget {
  final List<PontoSaldo> pontos;

  const GraficoSaldo({super.key, required this.pontos});

  @override
  Widget build(BuildContext context) {
    if (pontos.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: Text(
            'Sem movimentações no período.',
            style: TextStyle(color: AppColors.textoMarrom),
          ),
        ),
      );
    }
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: CustomPaint(painter: _PintorSaldo(pontos)),
    );
  }
}

class _PintorSaldo extends CustomPainter {
  final List<PontoSaldo> pontos;
  _PintorSaldo(this.pontos);

  String _abreviar(double v) {
    final a = v.abs();
    final sinal = v < 0 ? '-' : '';
    if (a >= 1000000) {
      return '${sinal}R\$ ${(a / 1000000).toStringAsFixed(1)} mi';
    }
    if (a >= 1000) return '${sinal}R\$ ${(a / 1000).toStringAsFixed(1)} mil';
    {
      return '${sinal}R\$ ${a.toStringAsFixed(0)}';
    }
  }

  void _texto(
    Canvas canvas,
    String texto,
    Offset pos,
    double largura, {
    bool direita = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: texto,
        style: const TextStyle(fontSize: 11, color: AppColors.textoMarrom),
      ),
      textDirection: TextDirection.ltr,
      textAlign: direita ? TextAlign.right : TextAlign.left,
      maxLines: 1,
    )..layout(minWidth: largura, maxWidth: largura);
    tp.paint(canvas, pos);
  }

  @override
  void paint(Canvas canvas, Size size) {
    const esq = 64.0, dir = 10.0, topo = 10.0, base = 26.0;
    final w = size.width - esq - dir;
    final h = size.height - topo - base;

    var minY = pontos.first.saldo;
    var maxY = pontos.first.saldo;
    for (final p in pontos) {
      minY = math.min(minY, p.saldo);
      maxY = math.max(maxY, p.saldo);
    }
    minY = math.min(minY, 0.0);
    if (maxY - minY < 1) maxY = minY + 1;

    final t0 = pontos.first.data.millisecondsSinceEpoch.toDouble();
    final t1 = pontos.last.data.millisecondsSinceEpoch.toDouble();
    final dt = t1 - t0;

    Offset ponto(PontoSaldo p) {
      final x = dt <= 0
          ? esq + w / 2
          : esq + (p.data.millisecondsSinceEpoch - t0) / dt * w;
      final y = topo + h - (p.saldo - minY) / (maxY - minY) * h;
      return Offset(x, y);
    }

    final grade = Paint()
      ..color = const Color(0xFFE5C9BD)
      ..strokeWidth = 1;
    for (var i = 0; i <= 2; i++) {
      final valor = minY + (maxY - minY) * i / 2;
      final y = topo + h - h * i / 2;
      canvas.drawLine(Offset(esq, y), Offset(esq + w, y), grade);
      _texto(
        canvas,
        _abreviar(valor),
        Offset(0, y - 7),
        esq - 6,
        direita: true,
      );
    }

    final linha = Path();
    final area = Path();
    for (var i = 0; i < pontos.length; i++) {
      final o = ponto(pontos[i]);
      if (i == 0) {
        linha.moveTo(o.dx, o.dy);
        area.moveTo(o.dx, topo + h);
        area.lineTo(o.dx, o.dy);
      } else {
        linha.lineTo(o.dx, o.dy);
        area.lineTo(o.dx, o.dy);
      }
    }
    area.lineTo(ponto(pontos.last).dx, topo + h);
    area.close();

    canvas.drawPath(
      area,
      Paint()
        ..color = const Color(0x33BD624D)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      linha,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round,
    );
    if (pontos.length <= 60) {
      final preenchimento = Paint()..color = AppColors.primary;
      for (final p in pontos) {
        canvas.drawCircle(ponto(p), 3.5, preenchimento);
      }
    }

    _texto(
      canvas,
      formatarDataCurta(pontos.first.data),
      Offset(esq, topo + h + 6),
      80,
    );
    if (pontos.length > 1) {
      _texto(
        canvas,
        formatarDataCurta(pontos.last.data),
        Offset(esq + w - 80, topo + h + 6),
        80,
        direita: true,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PintorSaldo oldDelegate) =>
      oldDelegate.pontos != pontos;
}
