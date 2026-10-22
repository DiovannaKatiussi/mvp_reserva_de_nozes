import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mvp_financeiro/util.dart';

/// RN-FIN-04
const List<String> origensAporte = [
  'Salário',
  'Freelance',
  'Presente',
  'Rendimentos',
  'Compra evitada',
  'Outro',
];

/// RN-FIN-05
const List<String> motivosRetirada = [
  'Emergência',
  'Compra planejada',
  'Desistência da meta',
  'Outro',
];

/// RN-CAI-10
const List<String> nomesPrioridade = ['Alta', 'Média', 'Baixa'];

/// RN-CAI-03
const int limiteMetasAtivas = 3;

enum TipoMov { aporte, retirada }

enum StatusCaixinha { ativa, concluida, desistida }

enum FaixaPrazo { urgente, atencao, tranquilo }

enum TipoAlerta { inatividade, quaseConcluida, prazo }

DateTime _data(dynamic v) => v is Timestamp ? v.toDate() : DateTime.now();
double _num(dynamic v) => v is num ? v.toDouble() : 0.0;

class Usuario {
  final String uid;
  final String nome;
  final String email;
  final int avatar;
  final double? rendaMensal;

  const Usuario({
    required this.uid,
    required this.nome,
    required this.email,
    required this.avatar,
    required this.rendaMensal,
  });

  factory Usuario.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? <String, dynamic>{};
    return Usuario(
      uid: doc.id,
      nome: (d['nome'] as String?) ?? '',
      email: (d['email'] as String?) ?? '',
      avatar: (d['avatar'] as num?)?.toInt() ?? 0,
      rendaMensal: (d['rendaMensal'] as num?)?.toDouble(),
    );
  }
}

class Caixinha {
  final String id;
  final String nome;
  final double valorAlvo;
  final DateTime dataLimite;
  final int prioridade;
  final bool reserva; // Reserva de Emergência
  final StatusCaixinha status;
  final double valorMaximo;
  final DateTime criadoEm;

  const Caixinha({
    required this.id,
    required this.nome,
    required this.valorAlvo,
    required this.dataLimite,
    required this.prioridade,
    required this.reserva,
    required this.status,
    required this.valorMaximo,
    required this.criadoEm,
  });

  bool get ativa => status == StatusCaixinha.ativa;

  factory Caixinha.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? <String, dynamic>{};
    return Caixinha(
      id: doc.id,
      nome: (d['nome'] as String?) ?? '',
      valorAlvo: _num(d['valorAlvo']),
      dataLimite: _data(d['dataLimite']),
      prioridade: (d['prioridade'] as num?)?.toInt() ?? 1,
      reserva: (d['reserva'] as bool?) ?? false,
      status: StatusCaixinha.values.firstWhere(
        (s) => s.name == d['status'],
        orElse: () => StatusCaixinha.ativa,
      ),
      valorMaximo: _num(d['valorMaximo']),
      criadoEm: _data(d['criadoEm']),
    );
  }

  Map<String, dynamic> toMap() => {
    'nome': nome,
    'valorAlvo': valorAlvo,
    'dataLimite': Timestamp.fromDate(dataLimite),
    'prioridade': prioridade,
    'reserva': reserva,
    'status': status.name,
    'valorMaximo': valorMaximo,
    'criadoEm': Timestamp.fromDate(criadoEm),
  };
}

class Movimentacao {
  final String id;
  final TipoMov tipo;
  final String nome;
  final double valor;
  final DateTime data;
  final String categoria; // origem (aporte) ou motivo (retirada)
  final String caixinhaId;
  final String descricao;
  final DateTime criadoEm;

  const Movimentacao({
    required this.id,
    required this.tipo,
    required this.nome,
    required this.valor,
    required this.data,
    required this.categoria,
    required this.caixinhaId,
    required this.descricao,
    required this.criadoEm,
  });

  factory Movimentacao.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? <String, dynamic>{};
    return Movimentacao(
      id: doc.id,
      tipo: d['tipo'] == 'retirada' ? TipoMov.retirada : TipoMov.aporte,
      nome: (d['nome'] as String?) ?? '',
      valor: _num(d['valor']),
      data: _data(d['data']),
      categoria: (d['categoria'] as String?) ?? '',
      caixinhaId: (d['caixinhaId'] as String?) ?? '',
      descricao: (d['descricao'] as String?) ?? '',
      criadoEm: _data(d['criadoEm']),
    );
  }

  Map<String, dynamic> toMap() => {
    'tipo': tipo.name,
    'nome': nome,
    'valor': valor,
    'data': Timestamp.fromDate(data),
    'categoria': categoria,
    'caixinhaId': caixinhaId,
    'descricao': descricao,
    'criadoEm': Timestamp.fromDate(criadoEm),
  };
}

class Resumo {
  final List<Caixinha> caixinhas;
  final List<Movimentacao> movs;

  const Resumo(this.caixinhas, this.movs);

  Caixinha? porId(String id) {
    for (final c in caixinhas) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// RF-FIN-01.1 e RF-FIN-04.1
  double saldoDe(String id) {
    var s = 0.0;
    for (final m in movs) {
      if (m.caixinhaId == id) {
        s += m.tipo == TipoMov.aporte ? m.valor : -m.valor;
      }
    }
    return s;
  }

  double progressoDe(Caixinha c) =>
      c.valorAlvo <= 0 ? 0 : saldoDe(c.id) / c.valorAlvo;

  /// RF-CAI-07
  double aportadoNoMes(String id) {
    final h = hoje();
    var s = 0.0;
    for (final m in movs) {
      if (m.caixinhaId == id &&
          m.tipo == TipoMov.aporte &&
          m.data.year == h.year &&
          m.data.month == h.month) {
        s += m.valor;
      }
    }
    return s;
  }

  /// RF-CAI-11 e RN-CAI-07
  double valorMaximoDe(Caixinha c) => math.max(c.valorMaximo, saldoDe(c.id));

  /// RN-CAI-04
  List<Caixinha> get ativas {
    final lista = caixinhas.where((c) => c.ativa).toList();
    lista.sort((a, b) {
      if (a.reserva != b.reserva) return a.reserva ? -1 : 1;
      final p = a.prioridade.compareTo(b.prioridade);
      if (p != 0) return p;
      final d = a.dataLimite.compareTo(b.dataLimite);
      if (d != 0) return d;
      return progressoDe(b).compareTo(progressoDe(a));
    });
    return lista;
  }

  List<Caixinha> get arquivadas {
    final lista = caixinhas.where((c) => !c.ativa).toList();
    lista.sort((a, b) => a.nome.compareTo(b.nome));
    return lista;
  }

  int get metasAtivas => caixinhas.where((c) => c.ativa && !c.reserva).length;

  /// RF-FIN-09
  double get saldoAtual {
    var s = 0.0;
    for (final c in caixinhas) {
      if (c.ativa) s += saldoDe(c.id);
    }
    return s;
  }

  List<Movimentacao> movsDe(String id) {
    final lista = movs.where((m) => m.caixinhaId == id).toList();
    lista.sort((a, b) {
      final d = b.data.compareTo(a.data);
      return d != 0 ? d : b.criadoEm.compareTo(a.criadoEm);
    });
    return lista;
  }
}

/// RN-CAI-01
FaixaPrazo faixaDoPrazo(DateTime limite) {
  final d = diasAte(limite);
  if (d < 30) return FaixaPrazo.urgente;
  if (d <= 90) return FaixaPrazo.atencao;
  return FaixaPrazo.tranquilo;
}

/// RN-FIN-03
String? validarSaldos(
  Resumo r, {
  Movimentacao? remover,
  Movimentacao? adicionar,
}) {
  final restantes = r.movs
      .where((m) => remover == null || m.id != remover.id)
      .toList();
  if (adicionar != null) restantes.add(adicionar);

  final afetados = <String>{
    if (remover != null) remover.caixinhaId,
    if (adicionar != null) adicionar.caixinhaId,
  };

  for (final id in afetados) {
    var saldo = 0.0;
    for (final m in restantes) {
      if (m.caixinhaId == id) {
        saldo += m.tipo == TipoMov.aporte ? m.valor : -m.valor;
      }
    }
    if (saldo < -0.005) {
      final nome = r.porId(id)?.nome ?? 'caixinha';
      if (adicionar != null &&
          adicionar.tipo == TipoMov.retirada &&
          adicionar.caixinhaId == id) {
        final disponivel = math.max(0.0, saldo + adicionar.valor);
        return 'A retirada não pode ser maior que o saldo da caixinha "$nome" (${formatarReais(disponivel)}).';
      }
      return 'Esta alteração deixaria o saldo da caixinha "$nome" negativo.';
    }
  }
  return null;
}

class PontoSaldo {
  final DateTime data;
  final double saldo;
  const PontoSaldo(this.data, this.saldo);
}

List<PontoSaldo> pontosSaldo(
  List<Movimentacao> todas, {
  DateTime? inicio,
  DateTime? fim,
}) {
  final ord = [...todas]..sort((a, b) => a.data.compareTo(b.data));
  var saldo = 0.0;
  var abertura = 0.0;
  final pontos = <PontoSaldo>[];
  for (final m in ord) {
    final delta = m.tipo == TipoMov.aporte ? m.valor : -m.valor;
    if (inicio != null && m.data.isBefore(inicio)) {
      saldo += delta;
      abertura = saldo;
      continue;
    }
    if (fim != null && m.data.isAfter(fim)) break;
    saldo += delta;
    if (pontos.isNotEmpty && pontos.last.data == m.data) {
      pontos[pontos.length - 1] = PontoSaldo(m.data, saldo);
    } else {
      pontos.add(PontoSaldo(m.data, saldo));
    }
  }
  if (inicio != null && (pontos.isEmpty || pontos.first.data != inicio)) {
    pontos.insert(0, PontoSaldo(inicio, abertura));
  }
  return pontos;
}

// RF-CAI-12

class Alerta {
  final TipoAlerta tipo;
  final String texto;
  const Alerta(this.tipo, this.texto);
}

List<Alerta> gerarAlertas(Resumo r) {
  final alertas = <Alerta>[];
  for (final c in r.ativas) {
    final p = r.progressoDe(c);

    // RF-CAI-12.1:
    DateTime ultimo = c.criadoEm;
    for (final m in r.movs) {
      if (m.caixinhaId == c.id &&
          m.tipo == TipoMov.aporte &&
          m.data.isAfter(ultimo)) {
        ultimo = m.data;
      }
    }
    final semAporte = hoje()
        .difference(DateTime(ultimo.year, ultimo.month, ultimo.day))
        .inDays;
    if (semAporte >= 30) {
      alertas.add(
        Alerta(
          TipoAlerta.inatividade,
          'Faz mais de 1 mês que você não faz um aporte em "${c.nome}".',
        ),
      );
    }

    // RF-CAI-12.2
    if (p >= 0.9 && p < 1.0) {
      alertas.add(
        Alerta(
          TipoAlerta.quaseConcluida,
          '"${c.nome}" já atingiu ${formatarPercentual(p)} da meta. Falta pouco!',
        ),
      );
    }

    // RF-CAI-12.3
    if (faixaDoPrazo(c.dataLimite) == FaixaPrazo.urgente && p < 1.0) {
      final d = diasAte(c.dataLimite);
      alertas.add(
        Alerta(
          TipoAlerta.prazo,
          d < 0
              ? 'O prazo de "${c.nome}" venceu há ${-d} dia(s).'
              : 'Faltam $d dia(s) para o prazo de "${c.nome}".',
        ),
      );
    }
  }
  return alertas;
}
