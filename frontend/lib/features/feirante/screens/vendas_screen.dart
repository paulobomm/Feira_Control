import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/feirante_provider.dart';

class VendasScreen extends StatefulWidget {
  const VendasScreen({super.key});

  @override
  State<VendasScreen> createState() => _VendasScreenState();
}

class _VendasScreenState extends State<VendasScreen> {
  final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final _dateFmt = DateFormat('dd/MM/yyyy HH:mm');
  final _apiDateFmt = DateFormat('yyyy-MM-dd');
  DateTime? _filtroInicio;
  DateTime? _filtroFim;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<FeiranteProvider>().fetchVendas(),
    );
  }

  Future<void> _selecionarFiltro() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
            colorScheme:
                const ColorScheme.light(primary: Colors.deepOrange)),
        child: child!,
      ),
    );
    if (range != null) {
      setState(() {
        _filtroInicio = range.start;
        _filtroFim = range.end;
      });
      if (context.mounted) {
        context.read<FeiranteProvider>().fetchVendas(
              dataInicio: _apiDateFmt.format(range.start),
              dataFim: _apiDateFmt.format(range.end),
            );
      }
    }
  }

  void _limparFiltro() {
    setState(() {
      _filtroInicio = null;
      _filtroFim = null;
    });
    context.read<FeiranteProvider>().fetchVendas();
  }

  @override
  Widget build(BuildContext context) {
    final dateFmtSimple = DateFormat('dd/MM');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Vendas'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_filtroInicio != null
                ? Icons.filter_alt
                : Icons.filter_alt_outlined),
            onPressed: _selecionarFiltro,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_filtroInicio != null)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.date_range,
                      size: 16, color: Colors.deepOrange),
                  const SizedBox(width: 6),
                  Text(
                    '${dateFmtSimple.format(_filtroInicio!)} → ${dateFmtSimple.format(_filtroFim!)}',
                    style: const TextStyle(color: Colors.deepOrange),
                  ),
                  const Spacer(),
                  TextButton(
                      onPressed: _limparFiltro,
                      child: const Text('Limpar filtro')),
                ],
              ),
            ),
          Expanded(
            child: Consumer<FeiranteProvider>(
              builder: (context, provider, _) {
                if (provider.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.vendas.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Nenhuma venda encontrada'),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => provider.fetchVendas(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.vendas.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final v = provider.vendas[index];
                      return Card(
                        child: ListTile(
                          onTap: () =>
                              context.push('/feirante/vendas/${v.id}'),
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFFBE9E7),
                            child: Icon(Icons.receipt,
                                color: Colors.deepOrange),
                          ),
                          title: Text(
                            _currency.format(v.total),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.deepOrange),
                          ),
                          subtitle: Text(_dateFmt.format(v.createdAt)),
                          trailing:
                              const Icon(Icons.chevron_right),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
