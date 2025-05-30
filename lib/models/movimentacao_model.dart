class Movimentacao {
  int? id_movimentacao;
  int id_produtos;
  int id_turma;
  int id_usuarios;
  String tipo;
  int quantidade;
  DateTime? data_saida;

  Movimentacao({
    this.id_movimentacao,
    required this.id_produtos,
    required this.id_turma,
    required this.id_usuarios,
    required this.tipo,
    required this.quantidade,
    this.data_saida,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_movimentacao': id_movimentacao,
      'id_produtos': id_produtos,
      'id_turma': id_turma,
      'id_usuarios': id_usuarios,
      'tipo': tipo,
      'quantidade': quantidade,
      'data_saida': data_saida?.toIso8601String(),
    };
  }

  factory Movimentacao.fromMap(Map<String, dynamic> map) {
    return Movimentacao(
      id_movimentacao: map['id_movimentacao'],
      id_produtos: map['id_produtos'],
      id_turma: map['id_turma'],
      id_usuarios: map['id_usuarios'],
      tipo: map['tipo'], // <-- Incluído no fromMap
      quantidade: map['quantidade'], // <-- Incluído no fromMap
      data_saida:
          map['data_saida'] != null ? DateTime.parse(map['data_saida']) : null,
    );
  }
}
