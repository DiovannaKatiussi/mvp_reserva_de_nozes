import 'package:flutter/material.dart';
import 'package:mvp_financeiro/paleta.dart';
import 'package:mvp_financeiro/util.dart';
import 'package:mvp_financeiro/wdg_avatar.dart';

class CabecalhoInicio extends StatelessWidget {
  final String nome;
  final int avatar;
  final double saldo;
  final int alertas;
  final VoidCallback? onNotificacoes;

  const CabecalhoInicio({
    super.key,
    required this.nome,
    required this.avatar,
    required this.saldo,
    this.alertas = 0,
    this.onNotificacoes,
  });

  @override
  Widget build(BuildContext context) {
    final topo = MediaQuery.of(context).padding.top;
    final primeiroNome = nome.trim().split(' ').first;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topo + 16, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.secondary, AppColors.primary],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Color(0x33BD624D),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Color(0x22000000), blurRadius: 8),
                  ],
                ),
                child: AvatarImagem(indice: avatar, tamanho: 52),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Olá,',
                      style: TextStyle(
                        color: AppColors.primaryBG,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      primeiroNome.isEmpty ? 'Usuário' : primeiroNome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              _SinoNotificacoes(quantidade: alertas, onTap: onNotificacoes),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Saldo total guardado',
                  style: TextStyle(
                    color: AppColors.primaryBG,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formatarReais(saldo),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
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

class _SinoNotificacoes extends StatelessWidget {
  final int quantidade;
  final VoidCallback? onTap;

  const _SinoNotificacoes({required this.quantidade, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: quantidade > 0
          ? 'Notificações, $quantidade novas'
          : 'Notificações',
      child: Material(
        color: Colors.white.withValues(alpha: 0.22),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Icon(
                  quantidade > 0
                      ? Icons.notifications_active_outlined
                      : Icons.notifications_none_rounded,
                  color: Colors.white,
                  size: 26,
                ),
                if (quantidade > 0)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: AppColors.perigo,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        quantidade > 9 ? '9+' : '$quantidade',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
