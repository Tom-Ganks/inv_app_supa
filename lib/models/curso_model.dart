class Curso {
  int? id_cursos;
  String nome;
  String? turma;

  Curso({
    this.id_cursos,
    required this.nome,
    this.turma,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_cursos': id_cursos,
      'nome': nome,
      'turma': turma,
    };
  }

  factory Curso.fromMap(Map<String, dynamic> map) {
    return Curso(
      id_cursos: map['id_cursos'],
      nome: map['nome'],
      turma: map['turma'],
    );
  }
}
