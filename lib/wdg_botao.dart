import 'package:flutter/material.dart';
import 'package:mvp_financeiro/paleta.dart';

class BotaoPrincipal extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final bool carregando;
  final Color cor;
  final Color corTexto;

  const BotaoPrincipal({
    super.key,
    required this.texto,
    required this.onPressed,
    this.carregando = false,
    this.cor = AppColors.primary,
    this.corTexto = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: cor,
          foregroundColor: corTexto,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: carregando ? null : onPressed,
        child: carregando
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: corTexto),
              )
            : Text(
                texto,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }
}
