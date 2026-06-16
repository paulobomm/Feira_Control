class Feirante {
  final String id;
  final String nome;
  final String email;
  final String? telefone;

  Feirante({
    required this.id,
    required this.nome,
    required this.email,
    this.telefone,
  });

  factory Feirante.fromJson(Map<String, dynamic> j) => Feirante(
        id: j['id'] as String,
        nome: j['nome'] as String,
        email: j['email'] as String,
        telefone: j['telefone'] as String?,
      );
}

class Barraca {
  final String id;
  final String nome;
  final String? localizacao;
  final String? feiranteId;

  Barraca({
    required this.id,
    required this.nome,
    this.localizacao,
    this.feiranteId,
  });

  factory Barraca.fromJson(Map<String, dynamic> j) => Barraca(
        id: j['id'] as String,
        nome: j['nome'] as String,
        localizacao: j['localizacao'] as String?,
        feiranteId: j['feirante_id'] as String?,
      );
}

class Relatorio {
  final int totalVendas;
  final String faturamentoTotal;
  final Map<String, dynamic> periodo;

  Relatorio({
    required this.totalVendas,
    required this.faturamentoTotal,
    required this.periodo,
  });

  factory Relatorio.fromJson(Map<String, dynamic> j) => Relatorio(
        totalVendas: j['total_vendas'] as int? ?? 0,
        faturamentoTotal: j['faturamento_total']?.toString() ?? '0.00',
        periodo: j['periodo'] as Map<String, dynamic>? ?? {},
      );
}
