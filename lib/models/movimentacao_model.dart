class Movimentacao {
  int? id_movimentacao;
  int id_produtos;
  int id_usuarios;
  int? id_turma;
  int quantidade;
  DateTime? data_saida;
  String tipo;
  String? observacao;

  Movimentacao({
    this.id_movimentacao,
    required this.id_produtos,
    required this.id_usuarios,
    this.id_turma,
    required this.quantidade,
    this.data_saida,
    required this.tipo,
    this.observacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_produtos': id_produtos,
      'id_usuarios': id_usuarios,
      'id_turma': id_turma,
      'quantidade': quantidade,
      'data_saida': data_saida?.toIso8601String(),
      'tipo': tipo,
      'observacao': observacao,
    };
  }

  factory Movimentacao.fromMap(Map<String, dynamic> map) {
    return Movimentacao(
      id_movimentacao: map['id_movimentacao'],
      id_produtos: map['id_produtos'],
      id_usuarios: map['id_usuarios'],
      id_turma: map['id_turma'],
      quantidade: map['quantidade'] ?? 0,
      data_saida:
          map['data_saida'] != null ? DateTime.parse(map['data_saida']) : null,
      tipo: map['tipo'] ?? 'entrada',
      observacao: map['observacao'],
    );
  }
}
