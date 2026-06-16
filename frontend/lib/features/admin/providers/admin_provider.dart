import 'package:flutter/material.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/http_client.dart';
import '../models/admin_models.dart';

class AdminProvider extends ChangeNotifier {
  List<Feirante> feirantes = [];
  List<Barraca> barracas = [];
  Relatorio? relatorio;
  bool loading = false;
  String? error;

  Future<void> fetchFeirantes() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final res = await HttpClient.admin.get(ApiConstants.feirantes);
      feirantes = (res.data as List)
          .map((e) => Feirante.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      error = 'Erro ao carregar feirantes: $e';
    }
    loading = false;
    notifyListeners();
  }

  Future<bool> cadastrarFeirante({
    required String nome,
    required String email,
    String? telefone,
  }) async {
    try {
      await HttpClient.admin.post(ApiConstants.feirantes, data: {
        'nome': nome,
        'email': email,
        if (telefone != null && telefone.isNotEmpty) 'telefone': telefone,
      });
      await fetchFeirantes();
      return true;
    } catch (_) {
      error = 'Erro ao cadastrar feirante';
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchBarracas() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final res = await HttpClient.admin.get(ApiConstants.barracas);
      barracas = (res.data as List)
          .map((e) => Barraca.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      error = 'Erro ao carregar barracas: $e';
    }
    loading = false;
    notifyListeners();
  }

  Future<bool> cadastrarBarraca({
    required String nome,
    String? localizacao,
    String? feiranteId,
  }) async {
    try {
      await HttpClient.admin.post(ApiConstants.barracas, data: {
        'nome': nome,
        if (localizacao != null && localizacao.isNotEmpty)
          'localizacao': localizacao,
        if (feiranteId != null) 'feirante_id': feiranteId,
      });
      await fetchBarracas();
      return true;
    } catch (_) {
      error = 'Erro ao cadastrar barraca';
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchRelatorio(String dataInicio, String dataFim) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final res = await HttpClient.admin.get(
        ApiConstants.relatorios,
        queryParameters: {'dataInicio': dataInicio, 'dataFim': dataFim},
      );
      relatorio = Relatorio.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      error = 'Erro ao carregar relatório: $e';
    }
    loading = false;
    notifyListeners();
  }
}
