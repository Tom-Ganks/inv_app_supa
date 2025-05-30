class Notificacao {
  int? id;
  String solicitante_nome;
  String solicitante_cargo;
  String produto_nome;
  int quantidade;
  DateTime data_solicitacao;
  bool lida;
  int? id_movimentacao;
  String? observacao;
  String status;
  int? quantidade_aprovada;

  Notificacao({
    this.id,
    required this.solicitante_nome,
    required this.solicitante_cargo,
    required this.produto_nome,
    required this.quantidade,
    required this.data_solicitacao,
    this.lida = false,
    this.id_movimentacao,
    this.observacao,
    this.status = 'pendente',
    this.quantidade_aprovada,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'solicitante_nome': solicitante_nome,
      'solicitante_cargo': solicitante_cargo,
      'produto_nome': produto_nome,
      'quantidade': quantidade,
      'data_solicitacao': data_solicitacao.toIso8601String(),
      'lida': lida ? 1 : 0,
      'id_movimentacao': id_movimentacao,
      'observacao': observacao,
      'status': status,
      'quantidade_aprovada': quantidade_aprovada,
    };
  }

  factory Notificacao.fromMap(Map<String, dynamic> map) {
    return Notificacao(
      id: map['id'],
      solicitante_nome: map['solicitante_nome'],
      solicitante_cargo: map['solicitante_cargo'],
      produto_nome: map['produto_nome'],
      quantidade: map['quantidade'],
      data_solicitacao: DateTime.parse(map['data_solicitacao']),
      lida: map['lida'] == 1,
      id_movimentacao: map['id_movimentacao'],
      observacao: map['observacao'],
      status: map['status'] ?? 'pendente',
      quantidade_aprovada: map['quantidade_aprovada'],
    );
  }

  String getStatusDisplay() {
    switch (status) {
      case 'aprovado':
        return 'APROVADO';
      case 'parcial':
        return 'APROVADO PARCIALMENTE';
      case 'recusado':
        return 'RECUSADO';
      default:
        return 'PENDENTE';
    }
  }

  Color getStatusColor() {
    switch (status) {
      case 'aprovado':
        return Colors.green;
      case 'parcial':
        return Colors.orange;
      case 'recusado':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
