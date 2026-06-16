class Produto {
  final String id;
  final String nome;
  final String? descricao;
  final double precoUnitario;

  Produto({
    required this.id,
    required this.nome,
    this.descricao,
    required this.precoUnitario,
  });

  factory Produto.fromJson(Map<String, dynamic> j) => Produto(
        id: j['id'] as String,
        nome: j['nome'] as String,
        descricao: j['descricao'] as String?,
        precoUnitario: double.parse(j['preco_unitario'].toString()),
      );
}

class EstoqueItem {
  final String id;
  final String produtoId;
  final String produtoNome;
  final int quantidade;

  EstoqueItem({
    required this.id,
    required this.produtoId,
    required this.produtoNome,
    required this.quantidade,
  });

  factory EstoqueItem.fromJson(Map<String, dynamic> j) => EstoqueItem(
        id: j['id'] as String,
        produtoId: j['produto_id'] as String,
        produtoNome: j['produto_nome'] as String,
        quantidade: j['quantidade'] as int,
      );
}

class Venda {
  final String id;
  final double total;
  final DateTime createdAt;

  Venda({
    required this.id,
    required this.total,
    required this.createdAt,
  });

  factory Venda.fromJson(Map<String, dynamic> j) => Venda(
        id: j['id'] as String,
        total: double.parse(j['total'].toString()),
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}

class VendaDetalhe extends Venda {
  final List<ItemVenda> itens;

  VendaDetalhe({
    required super.id,
    required super.total,
    required super.createdAt,
    required this.itens,
  });

  factory VendaDetalhe.fromJson(Map<String, dynamic> j) => VendaDetalhe(
        id: j['id'] as String,
        total: double.parse(j['total'].toString()),
        createdAt: DateTime.parse(j['created_at'] as String),
        itens: (j['itens'] as List? ?? [])
            .map((e) => ItemVenda.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class ItemVenda {
  final String produtoId;
  final int quantidade;
  final double precoUnitario;
  final double subtotal;

  ItemVenda({
    required this.produtoId,
    required this.quantidade,
    required this.precoUnitario,
    required this.subtotal,
  });

  factory ItemVenda.fromJson(Map<String, dynamic> j) => ItemVenda(
        produtoId: j['produto_id'] as String,
        quantidade: j['quantidade'] as int,
        precoUnitario: double.parse(j['preco_unitario'].toString()),
        subtotal: double.parse(j['subtotal'].toString()),
      );
}
