class Produto {
  int? id_produtos;
  String nome;
  int medida;
  String? local;
  int entrada;
  int saida;
  int saldo;
  String? codigo;
  DateTime? data_entrada;

  Produto({
    this.id_produtos,
    required this.nome,
    required this.medida,
    this.local,
    required this.entrada,
    required this.saida,
    required this.saldo,
    this.codigo,
    this.data_entrada,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_produtos': id_produtos,
      'nome': nome,
      'medida': medida,
      'local': local,
      'entrada': entrada,
      'saida': saida,
      'saldo': saldo,
      'codigo': codigo,
      'data_entrada': data_entrada?.toIso8601String(),
    };
  }

  factory Produto.fromMap(Map<String, dynamic> map) {
    return Produto(
      id_produtos: map['id_produtos'],
      nome: map['nome'],
      medida: map['medida'],
      local: map['local'],
      entrada: map['entrada'],
      saida: map['saida'],
      saldo: map['saldo'],
      codigo: map['codigo'],
      data_entrada: map['data_entrada'] != null
          ? DateTime.parse(map['data_entrada'])
          : null,
    );
  }
}
