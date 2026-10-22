import 'package:flutter/material.dart';
import 'package:mvp_financeiro/util.dart';
import 'package:mvp_financeiro/wdg_avatar.dart';

class CabecalhoInicio extends StatelessWidget {
  final String nome;
  final int avatar;
  final double saldo;

  const CabecalhoInicio({
    super.key,
    required this.nome,
    required this.avatar,
    required this.saldo,
  });

  @override
  Widget build(BuildContext context) {
    final topo = MediaQuery.of(context).padding.top;
    final primeiroNome = nome.trim().split(' ').first;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, topo + 12, 16, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFD88B68),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            AvatarImagem(indice: avatar, tamanho: 52),
            const SizedBox(width: 10),
            Expanded(
              flex: 5,
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Olá '),
                    TextSpan(
                      text: primeiroNome.isEmpty ? 'Usuário' : primeiroNome,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const TextSpan(text: '!'),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 20, color: Colors.black),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              flex: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9C4AB),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Saldo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        formatarReais(saldo),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
