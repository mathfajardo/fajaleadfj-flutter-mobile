import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_fj/core/utils/formatters.dart';
import 'package:mobile_fj/models/cliente.dart';

void main() {
  test('Cliente.fromJson aceita mensalidade em string e ativo em 0/1', () {
    final c = Cliente.fromJson({
      'id': 1,
      'nome': 'Fulano',
      'numero': '1199998888',
      'plano': 'Pro',
      'mensalidade': '1234.50',
      'observacoes': null,
      'ativo': 0,
    });
    expect(c.mensalidade, 1234.5);
    expect(c.ativo, false);
    expect(Cliente.fromJson({'ativo': 1}).ativo, true);
  });

  test('formatarValor', () {
    expect(formatarValor(1234.5), 'R\$ 1.234,50');
    expect(formatarValor(0), 'R\$ 0,00');
    expect(formatarValor(1234567.891), 'R\$ 1.234.567,89');
  });

  test('formatarNumero', () {
    expect(formatarNumero('1199998888'), '11 9999-8888');
    expect(formatarNumero('119'), '11 9');
    expect(formatarNumero('5511999988887'), '5511999988887');
  });

  test('parseValor', () {
    expect(parseValor('1.234,56'), 1234.56);
    expect(parseValor('99.90'), 99.9);
    expect(parseValor('150'), 150);
  });

  test('NumeroInputFormatter limita a 10 dígitos', () {
    final r = NumeroInputFormatter().formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(text: '119999888877'),
    );
    expect(r.text, '11 9999-8888');
  });
}
