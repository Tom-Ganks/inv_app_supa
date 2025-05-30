class Usuario {
  int? id_usuarios;
  String nome;
  String telefone;
  String email;
  String endereco;
  int cargo;
  String senha;
  String status;
  int? turma;
  String cpf;
  String? foto;

  Usuario({
    this.id_usuarios,
    required this.nome,
    required this.telefone,
    required this.email,
    required this.endereco,
    required this.cargo,
    required this.senha,
    required this.status,
    this.turma,
    required this.cpf,
    this.foto,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_usuarios': id_usuarios,
      'nome': nome,
      'telefone': telefone,
      'email': email,
      'endereco': endereco,
      'cargo': cargo,
      'senha': senha,
      'status': status,
      'turma': turma,
      'cpf': cpf,
      'foto': foto,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id_usuarios: map['id_usuarios'],
      nome: map['nome'],
      telefone: map['telefone'],
      email: map['email'],
      endereco: map['endereco'],
      cargo: map['cargo'],
      senha: map['senha'],
      status: map['status'],
      turma: map['turma'],
      cpf: map['cpf'] ?? '',
      foto: map['foto'],
    );
  }
}
