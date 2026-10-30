import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mvp_financeiro/modelos.dart';
import 'package:mvp_financeiro/repositorio.dart';

T? dadosDe<T>(AsyncValue<T> v) =>
    v.when(data: (d) => d, loading: () => null, error: (_, _) => null);

final repositorioProvider = Provider<Repositorio>((ref) => Repositorio());

final authProvider = StreamProvider<User?>(
  (ref) => FirebaseAuth.instance.authStateChanges(),
);

final uidProvider = Provider<String?>(
  (ref) => dadosDe(ref.watch(authProvider))?.uid,
);

final usuarioProvider = StreamProvider<Usuario?>((ref) {
  final uid = ref.watch(uidProvider);
  if (uid == null) return Stream<Usuario?>.value(null);
  return ref.watch(repositorioProvider).usuarioStream(uid);
});

final caixinhasProvider = StreamProvider<List<Caixinha>>((ref) {
  final uid = ref.watch(uidProvider);
  if (uid == null) return Stream<List<Caixinha>>.value(const []);
  return ref.watch(repositorioProvider).caixinhasStream(uid);
});

final movimentacoesProvider = StreamProvider<List<Movimentacao>>((ref) {
  final uid = ref.watch(uidProvider);
  if (uid == null) return Stream<List<Movimentacao>>.value(const []);
  return ref.watch(repositorioProvider).movsStream(uid);
});

final resumoProvider = Provider<Resumo>((ref) {
  final caixinhas = dadosDe(ref.watch(caixinhasProvider)) ?? const <Caixinha>[];
  final movs =
      dadosDe(ref.watch(movimentacoesProvider)) ?? const <Movimentacao>[];
  return Resumo(caixinhas, movs);
});
