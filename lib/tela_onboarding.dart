import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mvp_financeiro/paleta.dart';
import 'package:mvp_financeiro/providers.dart';
import 'package:mvp_financeiro/util.dart';
import 'package:mvp_financeiro/wdg_botao.dart';
import 'package:mvp_financeiro/wdg_campo.dart';

/// RF-CAI-01 e RF-CAI-02
class TelaOnboarding extends ConsumerStatefulWidget {
  const TelaOnboarding({super.key});

  @override
  ConsumerState<TelaOnboarding> createState() => _TelaOnboardingState();
}

class _TelaOnboardingState extends ConsumerState<TelaOnboarding> {
  final _chave = GlobalKey<FormState>();
  final _renda = TextEditingController();
  bool _carregando = false;
  String? _erro;

  @override
  void dispose() {
    _renda.dispose();
    super.dispose();
  }

  Future<void> _continuar() async {
    if (!_chave.currentState!.validate()) return;
    final repo = ref.read(repositorioProvider);
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      await repo.concluirOnboarding(parseValor(_renda.text)!);
    } catch (_) {
      _erro = 'Não foi possível salvar agora. Tente novamente.';
    }
    if (mounted) setState(() => _carregando = false);
  }

  @override
  Widget build(BuildContext context) {
    final renda = parseValor(_renda.text);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Form(
              key: _chave,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Image(
                      image: AssetImage('assets/imagens/im_MascoteNozes.png'),
                      height: 180,
                      errorBuilder: _semImagem,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Vamos começar!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Qual é a sua renda mensal? Com ela criamos a sua Reserva de Emergência, que equivale a 3 vezes esse valor.',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textoMarrom,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _renda,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: validarValor,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.primaryText,
                    ),
                    decoration: decoracaoCampo(
                      'Renda mensal (R\$)',
                      ajuda: renda != null && renda > 0
                          ? 'Sua Reserva de Emergência será de ${formatarReais(renda * 3)}.'
                          : null,
                    ),
                  ),
                  if (_erro != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _erro!,
                      style: const TextStyle(
                        color: AppColors.perigo,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  BotaoPrincipal(
                    texto: 'Continuar',
                    carregando: _carregando,
                    onPressed: _continuar,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _semImagem(BuildContext context, Object erro, StackTrace? pilha) =>
    const Text('🐿️', style: TextStyle(fontSize: 80));
