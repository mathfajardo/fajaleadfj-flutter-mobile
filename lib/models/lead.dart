class Lead {
  static const statusDisponiveis = [
    'Novo',
    'Em atendimento',
    'Perdido',
    'Convertido',
  ];

  final int? id;
  final String nome;
  final String numero;
  final String status;
  final String? observacoes;

  Lead({
    this.id,
    required this.nome,
    required this.numero,
    required this.status,
    this.observacoes,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      id: json['id'] as int?,
      nome: json['nome']?.toString() ?? '',
      numero: json['numero']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      observacoes: json['observacoes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'numero': numero,
    'status': status,
    'observacoes': observacoes,
  };
}
