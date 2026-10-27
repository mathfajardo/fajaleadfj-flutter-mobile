import 'package:flutter/services.dart';

String formatarValor(double valor) {
  final partes = valor.toStringAsFixed(2).split('.');
  final inteiro = partes[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]}.',
  );
  return 'R\$ $inteiro,${partes[1]}';
}

String formatarNumero(String numero) {
  final d = numero.replaceAll(RegExp(r'\D'), '');
  if (d.length <= 2) return d;
  if (d.length <= 6) return '${d.substring(0, 2)} ${d.substring(2)}';
  if (d.length > 10) return d;
  return '${d.substring(0, 2)} ${d.substring(2, 6)}-${d.substring(6)}';
}

double parseValor(String texto) {
  final t = texto.contains(',')
      ? texto.replaceAll('.', '').replaceAll(',', '.')
      : texto;
  return double.tryParse(t) ?? 0;
}

class NumeroInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digitos = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digitos.length > 10) digitos = digitos.substring(0, 10);
    final texto = formatarNumero(digitos);
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}
