import 'package:flutter/material.dart';
import 'package:mvp_financeiro/paleta.dart';
import 'package:mvp_financeiro/wdg_cabecalho.dart';

class TelaTermos extends StatelessWidget {
  const TelaTermos({super.key});

  static const List<(String, String)> _secoes = [
    (
      '1. Sobre o aplicativo',
      'O Reserva de Nozes ajuda você a organizar metas de poupança (caixinhas) e a registrar aportes e retiradas. O app não movimenta dinheiro real nem acessa contas bancárias.',
    ),
    (
      '2. Dados coletados',
      'Coletamos apenas o necessário para o funcionamento: nome, e-mail, renda mensal informada, caixinhas e movimentações que você registrar.',
    ),
    (
      '3. Uso dos dados',
      'Seus dados são usados somente para exibir o seu progresso financeiro dentro do aplicativo. Não são vendidos nem compartilhados com terceiros.',
    ),
    (
      '4. Segurança',
      'A autenticação e o armazenamento são feitos com serviços do Firebase, e cada usuário só consegue acessar os próprios dados.',
    ),
    (
      '5. Exclusão de conta (LGPD)',
      'Você pode excluir a sua conta a qualquer momento em Perfil > Excluir conta. A exclusão apaga de forma permanente e irreversível todos os seus dados.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CabecalhoTela(titulo: 'Termos de uso'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Termos de Uso e Política de Privacidade',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textoMarrom,
                  ),
                ),
                const SizedBox(height: 16),
                for (final s in _secoes) ...[
                  Text(
                    s.$1,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textoMarrom,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.$2,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textoMarrom,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
