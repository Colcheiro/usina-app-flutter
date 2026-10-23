class Usuario {
  final int? id;
  final String nome;
  final String email;
  final String senha;
  final String? fotoPath;

  Usuario({
    this.id,
    required this.nome,
    required this.email,
    required this.senha,
    this.fotoPath,
  });
}
