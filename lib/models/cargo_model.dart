class Cargo {
  int? id_cargos;
  String cargo;
  String? matricula;

  Cargo({
    this.id_cargos,
    required this.cargo,
    this.matricula,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_cargos': id_cargos,
      'cargo': cargo,
      'matricula': matricula,
    };
  }

  factory Cargo.fromMap(Map<String, dynamic> map) {
    return Cargo(
      id_cargos: map['id_cargos'],
      cargo: map['cargo'],
      matricula: map['matricula'],
    );
  }

  @override
  String toString() {
    return 'Cargo(id_cargos: $id_cargos, cargo: $cargo, matricula: $matricula)';
  }
}
