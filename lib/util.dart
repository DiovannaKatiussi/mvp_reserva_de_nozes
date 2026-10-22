import 'package:flutter/material.dart';

DateTime hoje() {
  final agora = DateTime.now();
  return DateTime(agora.year, agora.month, agora.day);
}

int diasAte(DateTime data) {
  final h = hoje();
  final a = DateTime.utc(h.year, h.month, h.day);
  final b = DateTime.utc(data.year, data.month, data.day);
  return b.difference(a).inDays;
}

String doisDigitos(int n) => n.toString().padLeft(2, '0');

String formatarData(DateTime d) =>
    '${doisDigitos(d.day)}/${doisDigitos(d.month)}/${d.year}';

String formatarDataCurta(DateTime d) =>
    '${doisDigitos(d.day)}/${doisDigitos(d.month)}';

String formatarPercentual(double p) => '${(p * 100).round()}%';

/// RN-FIN-02
String formatarReais(double v) {
  final negativo = v < -0.004;
  final partes = v.abs().toStringAsFixed(2).split('.');
  final inteiro = partes[0];
  final buffer = StringBuffer();
  for (var i = 0; i < inteiro.length; i++) {
    final restante = inteiro.length - i;
    buffer.write(inteiro[i]);
    if (restante > 1 && restante % 3 == 1) buffer.write('.');
  }
  return '${negativo ? '-' : ''}R\$ ${buffer.toString()},${partes[1]}';
}

double? parseValor(String texto) {
  var t = texto.replaceAll('R\$', '').replaceAll(' ', '').trim();
  if (t.isEmpty) return null;
  if (t.contains(',')) {
    t = t.replaceAll('.', '').replaceAll(',', '.');
  } else if (RegExp(r'^\d{1,3}(\.\d{3})+$').hasMatch(t)) {
    t = t.replaceAll('.', '');
  }
  return double.tryParse(t);
}

String? validarEmail(String? v) {
  final t = (v ?? '').trim();
  if (t.isEmpty) return 'Informe seu e-mail.';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)) {
    return 'Informe um e-mail válido.';
  }
  return null;
}

/// RN-PER-01
String? validarSenha(String? v) {
  if ((v ?? '').length < 6) return 'A senha deve ter no mínimo 6 caracteres.';
  return null;
}

/// RN-FIN-01
String? validarValor(String? v) {
  final x = parseValor(v ?? '');
  if (x == null) return 'Informe um valor válido.';
  if (x <= 0) return 'O valor deve ser maior que zero.';
  return null;
}

void mostrarMensagem(BuildContext context, String texto) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
}

Future<bool> confirmarDialogo(
  BuildContext context, {
  required String titulo,
  required String mensagem,
  String confirmar = 'Confirmar',
}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(titulo),
      content: Text(mensagem),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(confirmar),
        ),
      ],
    ),
  );
  return r == true;
}
