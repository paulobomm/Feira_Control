import 'package:flutter/material.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/http_client.dart';
import '../models/feirante_models.dart';

class FeiranteProvider extends ChangeNotifier {
  List<Produto> produtos = [];
  List<EstoqueItem> estoque = [];
  List<Venda> vendas = [];
  VendaDetalhe? vendaDetalhe;
  bool loading = false;
  String? error;

  // ─── Produtos ─────────────────────────────────────────────────────────────

  Future<void> fetchProdutos() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final res = await HttpClient.feirante.get(ApiConstants.produtos);
      produtos = (res.data as List)
          .map((e) => Produto.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      error = 'Erro ao carregar produtos';
    }
    loading = false;
    notifyListeners();
  }

  Future<bool> cadastrarProduto({
    required String nome,
    String? descricao,
    required double precoUnitario,
  }) async {
    try {
      await HttpClient.feirante.post(ApiConstants.produtos, data: {
        'nome': nome,
        if (descricao != null && descricao.isNotEmpty) 'descricao': descricao,
        'preco_unitario': precoUnitario,
      });
      await fetchProdutos();
      return true;
    } catch (_) {
      error = 'Erro ao cadastrar produto';
      notifyListeners();
      return false;
    }
  }

  // ─── Estoque ──────────────────────────────────────────────────────────────

  Future<void> fetchEstoque() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final res = await HttpClient.feirante.get(ApiConstants.estoque);
      estoque = (res.data as List)
          .map((e) => EstoqueItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      error = 'Erro ao carregar estoque';
    }
    loading = false;
    notifyListeners();
  }

  Future<bool> ajustarEstoque(String produtoId, int quantidade) async {
    try {
      await HttpClient.feirante.patch(
        '${ApiConstants.estoque}/$produtoId',
        data: {'quantidade': quantidade},
      );
      await fetchEstoque();
      return true;
    } catch (_) {
      error = 'Erro ao ajustar estoque';
      notifyListeners();
      return false;
    }
  }

  // ─── Vendas ───────────────────────────────────────────────────────────────

  Future<void> fetchVendas({String? dataInicio, String? dataFim}) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final res = await HttpClient.feirante.get(
        ApiConstants.vendas,
        queryParameters: {
          if (dataInicio != null) 'dataInicio': dataInicio,
          if (dataFim != null) 'dataFim': dataFim,
        },
      );
      vendas = (res.data as List)
          .map((e) => Venda.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      error = 'Erro ao carregar vendas';
    }
    loading = false;
    notifyListeners();
  }

  Future<bool> registrarVenda(
      List<Map<String, dynamic>> itens) async {
    try {
      await HttpClient.feirante.post(
        ApiConstants.vendas,
        data: {'itens': itens},
      );
      await fetchVendas();
      return true;
    } catch (_) {
      error = 'Erro ao registrar venda';
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchVendaDetalhe(String id) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final res =
          await HttpClient.feirante.get('${ApiConstants.vendas}/$id');
      vendaDetalhe =
          VendaDetalhe.fromJson(res.data as Map<String, dynamic>);
    } catch (_) {
      error = 'Erro ao carregar venda';
    }
    loading = false;
    notifyListeners();
  }
}
