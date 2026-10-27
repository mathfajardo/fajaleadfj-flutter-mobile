import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

void mostrarMensagem(BuildContext context, String texto, {bool erro = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: erro ? AppColors.danger : AppColors.text,
      content: Text(texto),
    ),
  );
}
