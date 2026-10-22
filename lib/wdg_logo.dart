import 'package:flutter/material.dart';

final logoCompleta = Column(
  mainAxisSize: MainAxisSize.max,
  children: [
    Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0, 30, 0, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          'assets/imagens/im_Logo.png',
          width: 355.6,
          height: 144,
          fit: BoxFit.contain,
        ),
      ),
    ),
    ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        'assets/imagens/im_MascoteNozes.png',
        width: 322,
        height: 260,
        fit: BoxFit.contain,
      ),
    ),
  ],
);
