class ApiConstants {
  static const String authBaseUrl = 'http://localhost:3000';
  static const String adminBaseUrl = 'http://localhost:3001';
  static const String feiranteBaseUrl = 'http://localhost:3002';

  // Auth
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String me = '/auth/me';

  // Admin
  static const String feirantes = '/admin/feirantes';
  static const String barracas = '/admin/barracas';
  static const String relatorios = '/admin/relatorios';

  // Feirante
  static const String produtos = '/feirante/produtos';
  static const String estoque = '/feirante/estoque';
  static const String vendas = '/feirante/vendas';
}
