class UserModel {
  final String id;
  final String nome;
  final String email;
  final String role;

  UserModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.role,
  });

  bool get isAdmin => role == 'admin';
  bool get isFeirante => role == 'feirante';

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        nome: json['nome'] as String,
        email: json['email'] as String,
        role: json['role'] as String,
      );
}
