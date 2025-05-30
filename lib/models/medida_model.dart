class Medida {
  int? id_medida;
  String medida;
  String? descricao;

  Medida({
    this.id_medida,
    required this.medida,
    this.descricao,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_medida': id_medida,
      'medida': medida,
      'descricao': descricao,
    };
  }

  factory Medida.fromMap(Map<String, dynamic> map) {
    return Medida(
      id_medida: map['id_medida'],
      medida: map['medida'],
      descricao: map['descricao'],
    );
  }
}
