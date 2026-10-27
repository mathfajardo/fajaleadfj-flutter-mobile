import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_fj/models/lead.dart';

void main() {
  test('Lead.fromJson e toJson', () {
    final l = Lead.fromJson({
      'id': 1,
      'cliente_id': null,
      'nome': 'Fulano',
      'numero': '1199998888',
      'status': 'Em atendimento',
      'observacoes': null,
      'created_at': '01/01/2026 10:00:00',
    });
    expect(l.id, 1);
    expect(l.status, 'Em atendimento');
    expect(l.observacoes, null);
    expect(l.toJson(), {
      'nome': 'Fulano',
      'numero': '1199998888',
      'status': 'Em atendimento',
      'observacoes': null,
    });
  });
}
