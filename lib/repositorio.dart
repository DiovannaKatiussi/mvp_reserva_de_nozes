import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mvp_financeiro/modelos.dart';

/// RF-PER-02.1
String mensagemErroAuth(FirebaseAuthException e, {bool login = false}) {
  switch (e.code) {
    case 'email-already-in-use':
      return 'Este e-mail já está cadastrado.';
    case 'invalid-email':
      return 'Informe um e-mail válido.';
    case 'weak-password':
      return 'A senha deve ter no mínimo 6 caracteres.';
    case 'network-request-failed':
      return 'Sem conexão com a internet. Verifique sua rede.';
    case 'too-many-requests':
      return 'Muitas tentativas. Aguarde um pouco e tente novamente.';
    case 'invalid-credential':
    case 'wrong-password':
    case 'user-not-found':
    case 'invalid-login-credentials':
      return login ? 'E-mail ou senha incorretos.' : 'Senha incorreta.';
    default:
      return 'Ocorreu um erro. Tente novamente.';
  }
}

class Repositorio {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  DocumentReference<Map<String, dynamic>> _userDoc([String? id]) =>
      _db.collection('users').doc(id ?? uid);

  CollectionReference<Map<String, dynamic>> _caixinhas([String? id]) =>
      _userDoc(id).collection('caixinhas');

  CollectionReference<Map<String, dynamic>> _movs([String? id]) =>
      _userDoc(id).collection('movimentacoes');

  /// RNF-CON-01
  Future<void> _escrever(Future<void> operacao) =>
      operacao.timeout(const Duration(seconds: 3), onTimeout: () {});

  Stream<Usuario?> usuarioStream(String id) =>
      _userDoc(id).snapshots().map((s) => s.exists ? Usuario.fromDoc(s) : null);

  Stream<List<Caixinha>> caixinhasStream(String id) =>
      _caixinhas(id)
          .snapshots()
          .map((q) => q.docs.map(Caixinha.fromDoc).toList());

  Stream<List<Movimentacao>> movsStream(String id) =>
      _movs(id)
          .snapshots()
          .map((q) => q.docs.map(Movimentacao.fromDoc).toList());

  /// RF-PER-01 e RF-PER-01.4
  Future<void> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );
    await _userDoc(cred.user!.uid).set({
      'nome': nome.trim(),
      'email': email.trim(),
      'avatar': 0,
      'rendaMensal': null,
      'criadoEm': Timestamp.now(),
    });
  }

  Future<void> entrar(String email, String senha) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: senha);

  Future<void> sair() => _auth.signOut();

  Future<void> recuperarSenha(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  /// RF-PER-05
  Future<void> alterarSenha(String senhaAtual, String novaSenha) async {
    final user = _auth.currentUser!;
    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: senhaAtual,
    );
    await user.reauthenticateWithCredential(cred);
    await user.updatePassword(novaSenha);
  }

  /// RF-PER-04
  Future<void> atualizarPerfil({required String nome, required int avatar}) =>
      _escrever(_userDoc().update({'nome': nome.trim(), 'avatar': avatar}));

  /// RF-PER-07 / RN-PER-04
  Future<void> excluirConta(String senha) async {
    final user = _auth.currentUser!;
    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: senha,
    );
    await user.reauthenticateWithCredential(cred);
    final id = user.uid;
    await _apagarColecao(_movs(id));
    await _apagarColecao(_caixinhas(id));
    await _userDoc(id).delete();
    await user.delete();
  }

  Future<void> _apagarColecao(
    CollectionReference<Map<String, dynamic>> col,
  ) async {
    while (true) {
      final snap = await col.limit(400).get();
      if (snap.docs.isEmpty) break;
      final batch = _db.batch();
      for (final d in snap.docs) {
        batch.delete(d.reference);
      }
      await batch.commit();
    }
  }

  /// RF-CAI-01, RF-CAI-02 e RN-CAI-02
  Future<void> concluirOnboarding(double renda) {
    final agora = DateTime.now();
    final reserva = Caixinha(
      id: '',
      nome: 'Reserva de Emergência',
      valorAlvo: renda * 3,
      dataLimite: DateTime(agora.year + 1, agora.month, agora.day),
      prioridade: 0,
      reserva: true,
      status: StatusCaixinha.ativa,
      valorMaximo: 0,
      criadoEm: agora,
    );
    final batch = _db.batch();
    batch.update(_userDoc(), {'rendaMensal': renda});
    batch.set(_caixinhas().doc(), reserva.toMap());
    return _escrever(batch.commit());
  }

  // outras caixinhas

  Future<void> criarCaixinha({
    required String nome,
    required double valorAlvo,
    required DateTime dataLimite,
    required int prioridade,
  }) {
    final ref = _caixinhas().doc();
    final c = Caixinha(
      id: ref.id,
      nome: nome.trim(),
      valorAlvo: valorAlvo,
      dataLimite: dataLimite,
      prioridade: prioridade,
      reserva: false,
      status: StatusCaixinha.ativa,
      valorMaximo: 0,
      criadoEm: DateTime.now(),
    );
    return _escrever(ref.set(c.toMap()));
  }

  Future<void> editarCaixinha(
    String id, {
    String? nome,
    double? valorAlvo,
    DateTime? dataLimite,
    int? prioridade,
  }) {
    final dados = <String, dynamic>{
      if (nome != null) 'nome': nome.trim(),
      'valorAlvo': ?valorAlvo,
      if (dataLimite != null) 'dataLimite': Timestamp.fromDate(dataLimite),
      'prioridade': ?prioridade,
    };
    return _escrever(_caixinhas().doc(id).update(dados));
  }

  /// RF-CAI-10 e RN-CAI-09
  Future<void> concluirCaixinha(String id) => _escrever(
    _caixinhas().doc(id).update({'status': StatusCaixinha.concluida.name}),
  );

  /// RF-CAI-10.1 / RN-CAI-06
  Future<void> desistirDaCaixinha(
    Caixinha c,
    double saldo, {
    Caixinha? destino,
  }) {
    final batch = _db.batch();
    final agora = DateTime.now();
    final dia = DateTime(agora.year, agora.month, agora.day);
    final atualizacao = <String, dynamic>{
      'status': StatusCaixinha.desistida.name,
    };

    if (saldo > 0.004) {
      final retRef = _movs().doc();
      batch.set(
        retRef,
        Movimentacao(
          id: retRef.id,
          tipo: TipoMov.retirada,
          nome: 'Desistência da meta',
          valor: saldo,
          data: dia,
          categoria: 'Desistência da meta',
          caixinhaId: c.id,
          descricao: destino == null
              ? ''
              : 'Valor transferido para "${destino.nome}"',
          criadoEm: agora,
        ).toMap(),
      );
      if (saldo > c.valorMaximo) atualizacao['valorMaximo'] = saldo;

      if (destino != null) {
        final apRef = _movs().doc();
        batch.set(
          apRef,
          Movimentacao(
            id: apRef.id,
            tipo: TipoMov.aporte,
            nome: 'Transferência de "${c.nome}"',
            valor: saldo,
            data: dia,
            categoria: 'Outro',
            caixinhaId: destino.id,
            descricao:
                'Valor transferido de caixinha encerrada por desistência',
            criadoEm: agora,
          ).toMap(),
        );
      }
    }
    batch.update(_caixinhas().doc(c.id), atualizacao);
    return _escrever(batch.commit());
  }

  /// RF-CAI-09
  Future<void> excluirCaixinha(
    Caixinha c,
    List<Movimentacao> movsDaCaixinha, {
    Caixinha? redirecionarPara,
  }) {
    final ops = <void Function(WriteBatch)>[];
    for (final m in movsDaCaixinha) {
      final ref = _movs().doc(m.id);
      if (redirecionarPara != null) {
        ops.add((b) => b.update(ref, {'caixinhaId': redirecionarPara.id}));
      } else {
        ops.add((b) => b.delete(ref));
      }
    }
    ops.add((b) => b.delete(_caixinhas().doc(c.id)));
    return _escrever(_executarEmLotes(ops));
  }

  Future<void> _executarEmLotes(List<void Function(WriteBatch)> ops) async {
    for (var i = 0; i < ops.length; i += 400) {
      final batch = _db.batch();
      for (final op in ops.sublist(i, math.min(i + 400, ops.length))) {
        op(batch);
      }
      await batch.commit();
    }
  }

  /// RN-CAI-07
  Future<void> criarMov(Movimentacao m, {double? novoMaximo}) {
    final ref = _movs().doc();
    final batch = _db.batch();
    batch.set(ref, m.toMap());
    if (novoMaximo != null) {
      batch.update(_caixinhas().doc(m.caixinhaId), {'valorMaximo': novoMaximo});
    }
    return _escrever(batch.commit());
  }

  Future<void> atualizarMov(Movimentacao m) =>
      _escrever(_movs().doc(m.id).set(m.toMap()));

  Future<void> excluirMov(String id) => _escrever(_movs().doc(id).delete());
}
