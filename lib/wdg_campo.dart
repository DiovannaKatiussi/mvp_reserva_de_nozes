import 'package:flutter/material.dart';
import 'package:mvp_financeiro/paleta.dart';

OutlineInputBorder _borda(Color cor) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: cor, width: 1.5),
    );

InputDecoration decoracaoCampo(String rotulo, {Widget? sufixo, String? ajuda}) {
  return InputDecoration(
    labelText: rotulo,
    helperText: ajuda,
    helperMaxLines: 2,
    labelStyle: const TextStyle(
      color: AppColors.textoMarrom,
      fontWeight: FontWeight.w600,
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    suffixIcon: sufixo,
    border: _borda(AppColors.secondaryBG),
    enabledBorder: _borda(AppColors.secondaryBG),
    focusedBorder: _borda(AppColors.primary),
    errorBorder: _borda(AppColors.perigo),
    focusedErrorBorder: _borda(AppColors.perigo),
  );
}

class CampoTexto extends StatefulWidget {
  final TextEditingController controller;
  final String rotulo;
  final bool senha;
  final TextInputType? teclado;
  final String? Function(String?)? validador;
  final int maxLinhas;
  final String? ajuda;
  final TextCapitalization capitalizacao;

  const CampoTexto({
    super.key,
    required this.controller,
    required this.rotulo,
    this.senha = false,
    this.teclado,
    this.validador,
    this.maxLinhas = 1,
    this.ajuda,
    this.capitalizacao = TextCapitalization.none,
  });

  @override
  State<CampoTexto> createState() => _CampoTextoState();
}

class _CampoTextoState extends State<CampoTexto> {
  bool _oculto = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.senha && _oculto,
      keyboardType: widget.teclado,
      validator: widget.validador,
      maxLines: widget.senha ? 1 : widget.maxLinhas,
      textCapitalization: widget.capitalizacao,
      style: const TextStyle(fontSize: 16, color: AppColors.primaryText),
      decoration: decoracaoCampo(
        widget.rotulo,
        ajuda: widget.ajuda,
        sufixo: widget.senha
            ? IconButton(
                icon: Icon(
                  _oculto
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey,
                ),
                onPressed: () => setState(() => _oculto = !_oculto),
              )
            : null,
      ),
    );
  }
}
