import 'package:flutter/material.dart';
import 'package:mvp_financeiro/paleta.dart';

class AvatarImagem extends StatelessWidget {
  final int indice;
  final double tamanho;
  final bool borda;

  const AvatarImagem({
    super.key,
    required this.indice,
    this.tamanho = 56,
    this.borda = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamanho,
      height: tamanho,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFFF8E7),
        border: borda
            ? Border.all(color: AppColors.alternative, width: 4)
            : null,
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/imagens/avatar_${indice + 1}.png',
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            color: const Color(0xFFEEB7FF),
            alignment: Alignment.bottomCenter,
            child: Icon(
              Icons.person,
              size: tamanho * 0.85,
              color: const Color(0xFFF9E6FF),
            ),
          ),
        ),
      ),
    );
  }
}
