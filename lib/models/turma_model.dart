class Turma {
  int? id_turma;
  String turma;
  String? instrutor;
  int? curso;

  Turma({
    this.id_turma,
    required this.turma,
    this.instrutor,
    this.curso,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_turma': id_turma,
      'turma': turma,
      'instrutor': instrutor,
      'curso': curso,
    };
  }

  factory Turma.fromMap(Map<String, dynamic> map) {
    return Turma(
      id_turma: map['id_turma'],
      turma: map['turma'],
      instrutor: map['instrutor'],
      curso: map['curso'],
    );
  }
}
