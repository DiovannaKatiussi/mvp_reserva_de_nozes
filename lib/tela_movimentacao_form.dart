import 'dart:math' as math;

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

class TelaMovimentacaoForm extends ConsumerStatefulWidget {
  final TipoMov tipo;
  final Movimentacao? editar;
  final String? caixinhaId;

  const TelaMovimentacaoForm({
    super.key,
    required this.tipo,
    this.editar,
    this.caixinhaId,
  });

  @override
  ConsumerState<TelaMovimentacaoForm> createState() =>
      _TelaMovimentacaoFormState();
}

class _TelaMovimentacaoFormState extends ConsumerState<TelaMovimentacaoForm> {
  final _chave = GlobalKey<FormState>();
  late final TextEditingController _nome;
  late final TextEditingController _valor;
  late final TextEditingController _descricao;
  String? _categoria;
  String? _caixinhaId;
  late DateTime _data;
  String? _erroCategoria;
  String? _erroCaixinha;
  String? _erroGeral;
  bool _carregando = false;

  TipoMov get _tipo => widget.editar?.tipo ?? widget.tipo;
  bool get _aporte => _tipo == TipoMov.aporte;

  @override
  void initState() {
    super.initState();
    final e = widget.editar;
    _nome = TextEditingController(text: e?.nome ?? '');
    _valor = TextEditingController(
      text: e == null ? '' : e.valor.toStringAsFixed(2).replaceAll('.', ','),
    );
    _descricao = TextEditingController(text: e?.descricao ?? '');
    _categoria = e?.categoria;
    _data = e?.data ?? hoje();
    final ativas = ref.read(resumoProvider).ativas;
    _caixinhaId =
        e?.caixinhaId ??
        widget.caixinhaId ??
        (ativas.isNotEmpty ? ativas.first.id : null);
  }

  @override
  void dispose() {
    _nome.dispose();
    _valor.dispose();
    _descricao.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final formOk = _chave.currentState!.validate();
    setState(() {
      _erroGeral = null;
      _erroCategoria = _categoria == null
          ? (_aporte ? 'Selecione a origem.' : 'Selecione o motivo.')
          : null;
      _erroCaixinha = _caixinhaId == null ? 'Selecione a caixinha.' : null;
    });
    if (!formOk || _categoria == null || _caixinhaId == null) return;

    final resumo = ref.read(resumoProvider);
    final antiga = widget.editar;
    final novo = Movimentacao(
      id: antiga?.id ?? '',
      tipo: _tipo,
      nome: _nome.text.trim(),
      valor: parseValor(_valor.text)!,
      data: _data,
      categoria: _categoria!,
      caixinhaId: _caixinhaId!,
      descricao: _descricao.text.trim(),
      criadoEm: antiga?.criadoEm ?? DateTime.now(),
    );

    // RN-FIN-03
    final erro = validarSaldos(resumo, remover: antiga, adicionar: novo);
    if (erro != null) {
      setState(() => _erroGeral = erro);
      return;
    }

    final repo = ref.read(repositorioProvider);
    final navigator = Navigator.of(context);
    setState(() => _carregando = true);
    try {
      if (antiga == null) {
        double? novoMaximo;
        if (_tipo == TipoMov.retirada) {
          // RN-CAI-07
          final c = resumo.porId(novo.caixinhaId);
          final saldoAntes = resumo.saldoDe(novo.caixinhaId);
          if (c != null && saldoAntes > c.valorMaximo) {
            novoMaximo = math.max(saldoAntes, c.valorMaximo);
          }
        }
        await repo.criarMov(novo, novoMaximo: novoMaximo);
      } else {
        await repo.atualizarMov(novo);
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

  Future<void> _excluir() async {
    final antiga = widget.editar!;
    final erro = validarSaldos(ref.read(resumoProvider), remover: antiga);
    if (erro != null) {
      setState(() => _erroGeral = erro);
      return;
    }
    final confirmou = await confirmarDialogo(
      context,
      titulo: 'Excluir ${_aporte ? 'aporte' : 'retirada'}?',
      mensagem: 'O saldo e o progresso da caixinha serão recalculados. Esta ação não pode ser desfeita.',
      confirmar: 'Excluir',
    );
    if (!confirmou || !mounted) return;
    final navigator = Navigator.of(context);
    setState(() => _carregando = true);
    try {
      await ref.read(repositorioProvider).excluirMov(antiga.id);
      navigator.pop();
    } catch (_) {
      if (mounted) {
        setState(() {
          _carregando = false;
          _erroGeral = 'Não foi possível excluir. Tente novamente.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final resumo = ref.watch(resumoProvider);
    final editando = widget.editar != null;
    final opcoes = resumo.ativas.toList();
    if (_caixinhaId != null && !opcoes.any((c) => c.id == _caixinhaId)) {
      final atual = resumo.porId(_caixinhaId!);
      if (atual != null) opcoes.add(atual);
    }
    final titulo = editando
        ? (_aporte ? 'Editar Aporte' : 'Editar Retirada')
        : (_aporte ? 'Registrar Novo Aporte' : 'Registrar Nova Retirada');

    return Scaffold(
      body: Column(
        children: [
          CabecalhoTela(titulo: titulo),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Form(
                key: _chave,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CampoTexto(
                      controller: _nome,
                      rotulo: 'Nome',
                      capitalizacao: TextCapitalization.sentences,
                      validador: (v) =>
                          (v ?? '').trim().isEmpty ? 'Informe um nome.' : null,
                    ),
                    const SizedBox(height: 14),
                    CampoSelecao<String>(
                      rotulo: _aporte ? 'Origem' : 'Motivo',
                      valor: _categoria,
                      opcoes: _aporte ? origensAporte : motivosRetirada,
                      texto: (s) => s,
                      erro: _erroCategoria,
                      onChanged: (v) => setState(() {
                        _categoria = v;
                        _erroCategoria = null;
                      }),
                    ),
                    const SizedBox(height: 14),
                    CampoTexto(
                      controller: _valor,
                      rotulo: 'Valor (R\$)',
                      teclado: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validador: validarValor, // RN-FIN-01
                    ),
                    const SizedBox(height: 14),
                    CampoSelecao<String>(
                      rotulo: _aporte
                          ? 'Caixinha de destino'
                          : 'Caixinha de retirada',
                      valor: _caixinhaId,
                      opcoes: opcoes.map((c) => c.id).toList(),
                      texto: (id) => resumo.porId(id)?.nome ?? '',
                      erro: _erroCaixinha,
                      onChanged: (v) => setState(() {
                        _caixinhaId = v;
                        _erroCaixinha = null;
                      }),
                    ),
                    const SizedBox(height: 14),
                    CampoTexto(
                      controller: _descricao,
                      rotulo: 'Descrição (Opcional)',
                      maxLinhas: 3,
                      capitalizacao: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 8),
                    CampoData(
                      data: _data,
                      rotulo: 'Data',
                      primeira: DateTime(2000),
                      ultima: hoje(),
                      onChanged: (d) => setState(() => _data = d),
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
                    if (editando) ...[
                      const SizedBox(height: 12),
                      BotaoPrincipal(
                        texto: 'Excluir',
                        cor: AppColors.perigo,
                        corTexto: AppColors.primaryBG,
                        onPressed: _carregando ? null : _excluir,
                      ),
                    ],
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
