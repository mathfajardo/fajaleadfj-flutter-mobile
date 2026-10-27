class Cliente {
  final int? id;
  final String nome;
  final String numero;
  final String plano;
  final double mensalidade;
  final String? observacoes;
  final bool ativo;

  Cliente({
    this.id,
    required this.nome,
    required this.numero,
    required this.plano,
    required this.mensalidade,
    this.observacoes,
    this.ativo = true,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    final ativo = json['ativo'];
    return Cliente(
      id: json['id'] as int?,
      nome: json['nome']?.toString() ?? '',
      numero: json['numero']?.toString() ?? '',
      plano: json['plano']?.toString() ?? '',
      mensalidade: double.tryParse(json['mensalidade']?.toString() ?? '') ?? 0,
      observacoes: json['observacoes']?.toString(),
      ativo: ativo == null || ativo == true || ativo == 1 || ativo == '1',
    );
  }

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'numero': numero,
    'plano': plano,
    'mensalidade': mensalidade,
    'observacoes': observacoes,
    'ativo': ativo,
  };
}
