import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mvp_financeiro/paleta.dart';
import 'package:mvp_financeiro/providers.dart';
import 'package:mvp_financeiro/tela_home.dart';
import 'package:mvp_financeiro/tela_login.dart';
import 'package:mvp_financeiro/tela_onboarding.dart';
import 'package:mvp_financeiro/wdg_barra_nozes.dart';

class PortaoAutenticacao extends ConsumerWidget {
  const PortaoAutenticacao({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    return auth.when(
      loading: () => const _Carregando(),
      error: (_, _) => const TelaLogin(),
      data: (user) {
        if (user == null) return const TelaLogin();
        final usuario = ref.watch(usuarioProvider);
        return usuario.when(
          loading: () => const _Carregando(),
          error: (_, _) => const _Carregando(comSair: true),
          data: (u) {
            if (u == null) return const _Carregando(comSair: true);
            if (u.rendaMensal == null) return const TelaOnboarding();
            return const TelaHome();
          },
        );
      },
    );
  }
}

class _Carregando extends ConsumerWidget {
  final bool comSair;
  const _Carregando({this.comSair = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Castanha(altura: 56),
            const SizedBox(height: 16),
            const CircularProgressIndicator(color: AppColors.primary),
            if (comSair) ...[
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => ref.read(repositorioProvider).sair(),
                child: const Text('Sair'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
