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
  String? data_nascimento;

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
    this.data_nascimento,
  });

  Map<String, dynamic> toMap() {
    final map = {
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
      'data_nascimento': data_nascimento,
    };

    // Only include id_usuarios if it's not null
    if (id_usuarios != null) {
      map['id_usuarios'] = id_usuarios;
    }

    return map;
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
      data_nascimento: map['data_nascimento'],
    );
  }
}
