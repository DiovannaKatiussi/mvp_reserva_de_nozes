import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mvp_financeiro/modelos.dart';
import 'package:mvp_financeiro/paleta.dart';
import 'package:mvp_financeiro/providers.dart';
import 'package:mvp_financeiro/util.dart';
import 'package:mvp_financeiro/wdg_botao.dart';
import 'package:mvp_financeiro/wdg_cabecalho.dart';
import 'package:mvp_financeiro/wdg_campo.dart';
import 'package:mvp_financeiro/wdg_selecao.dart';

/// RF-CAI-04, RF-CAI-03 e RF-CAI-08
class TelaCaixinhaForm extends ConsumerStatefulWidget {
  final Caixinha? editar;
  const TelaCaixinhaForm({super.key, this.editar});

  @override
  ConsumerState<TelaCaixinhaForm> createState() => _TelaCaixinhaFormState();
}

class _TelaCaixinhaFormState extends ConsumerState<TelaCaixinhaForm> {
  final _chave = GlobalKey<FormState>();
  late final TextEditingController _nome;
  late final TextEditingController _valor;
  int? _prioridade;
  DateTime? _data;
  String? _erroPrioridade;
  String? _erroData;
  String? _erroGeral;
  bool _carregando = false;

  bool get _reserva => widget.editar?.reserva ?? false;

  @override
  void initState() {
    super.initState();
    final e = widget.editar;
    _nome = TextEditingController(text: e?.nome ?? '');
    _valor = TextEditingController(
      text: e == null
          ? ''
          : e.valorAlvo.toStringAsFixed(2).replaceAll('.', ','),
    );
    _prioridade = e?.prioridade;
    _data = e?.dataLimite;
  }

  @override
  void dispose() {
    _nome.dispose();
    _valor.dispose();
    super.dispose();
  }

  double get _minimoReserva {
    final renda = dadosDe(ref.read(usuarioProvider))?.rendaMensal ?? 0;
    return renda * 3; // RN-CAI-02
  }

  Future<void> _salvar() async {
    final formOk = _chave.currentState!.validate();
    setState(() {
      _erroGeral = null;
      _erroPrioridade = (!_reserva && _prioridade == null)
          ? 'Selecione a prioridade.'
          : null;
      _erroData = _data == null ? 'Selecione a data-limite.' : null;
    });
    if (!formOk || _data == null || (!_reserva && _prioridade == null)) return;

    final valor = parseValor(_valor.text)!;
    final editar = widget.editar;

    // RF-CAI-03
    if (_reserva && valor < _minimoReserva - 0.005) {
      setState(
        () => _erroGeral =
            'O valor da Reserva de Emergência não pode ser menor que ${formatarReais(_minimoReserva)} (3 vezes a sua renda).',
      );
      return;
    }

    final mudouData =
        editar == null ||
        DateTime(_data!.year, _data!.month, _data!.day) !=
            DateTime(
              editar.dataLimite.year,
              editar.dataLimite.month,
              editar.dataLimite.day,
            );
    if (mudouData && _data!.isBefore(hoje())) {
      setState(() => _erroData = 'A data-limite não pode estar no passado.');
      return;
    }

    // RN-CAI-03
    if (editar == null &&
        ref.read(resumoProvider).metasAtivas >= limiteMetasAtivas) {
      setState(
        () => _erroGeral =
            'Limite atingido: você já tem $limiteMetasAtivas caixinhas de meta ativas.',
      );
      return;
    }

    final repo = ref.read(repositorioProvider);
    final navigator = Navigator.of(context);
    setState(() => _carregando = true);
    try {
      if (editar == null) {
        await repo.criarCaixinha(
          nome: _nome.text,
          valorAlvo: valor,
          dataLimite: _data!,
          prioridade: _prioridade!,
        );
      } else if (_reserva) {
        await repo.editarCaixinha(
          editar.id,
          valorAlvo: valor,
          dataLimite: _data,
        );
      } else {
        await repo.editarCaixinha(
          editar.id,
          nome: _nome.text,
          valorAlvo: valor,
          dataLimite: _data,
          prioridade: _prioridade,
        );
      }
      navigator.pop();
    } catch (_) {
      if (mounted) {
        setState(() {
          _carregando = false;
          _erroGeral = 'Não foi possível salvar. Tente novamente.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.editar != null;
    return Scaffold(
      body: Column(
        children: [
          CabecalhoTela(
            titulo: _reserva
                ? 'Editar Reserva de Emergência'
                : (editando ? 'Editar Caixinha' : 'Nova Caixinha'),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Form(
                key: _chave,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_reserva) ...[
                      CampoTexto(
                        controller: _nome,
                        rotulo: 'Nome da meta',
                        capitalizacao: TextCapitalization.sentences,
                        validador: (v) => (v ?? '').trim().isEmpty
                            ? 'Informe o nome da meta.'
                            : null,
                      ),
                      const SizedBox(height: 14),
                    ],
                    CampoTexto(
                      controller: _valor,
                      rotulo: 'Valor-alvo (R\$)',
                      teclado: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validador: validarValor,
                      ajuda: _reserva
                          ? 'Mínimo: ${formatarReais(_minimoReserva)} (3 vezes a sua renda).'
                          : null,
                    ),
                    if (!_reserva) ...[
                      const SizedBox(height: 14),
                      CampoSelecao<int>(
                        rotulo: 'Prioridade',
                        valor: _prioridade,
                        opcoes: const [0, 1, 2],
                        texto: (i) => nomesPrioridade[i],
                        erro: _erroPrioridade,
                        onChanged: (v) => setState(() {
                          _prioridade = v;
                          _erroPrioridade = null;
                        }),
                      ),
                    ],
                    const SizedBox(height: 8),
                    CampoData(
                      data: _data,
                      rotulo: 'Data-limite',
                      primeira: DateTime(2000),
                      ultima: DateTime(2100),
                      erro: _erroData,
                      onChanged: (d) => setState(() {
                        _data = d;
                        _erroData = null;
                      }),
                    ),
                    if (_erroGeral != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _erroGeral!,
                        style: const TextStyle(
                          color: AppColors.perigo,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    BotaoPrincipal(
                      texto: 'Salvar',
                      cor: AppColors.botaoClaro,
                      corTexto: Colors.black,
                      carregando: _carregando,
                      onPressed: _salvar,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
