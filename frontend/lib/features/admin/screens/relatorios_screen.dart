import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';

class RelatoriosScreen extends StatefulWidget {
  const RelatoriosScreen({super.key});

  @override
  State<RelatoriosScreen> createState() => _RelatoriosScreenState();
}

class _RelatoriosScreenState extends State<RelatoriosScreen> {
  DateTime _inicio = DateTime.now().subtract(const Duration(days: 30));
  DateTime _fim = DateTime.now();
  final _fmt = DateFormat('dd/MM/yyyy');
  final _fmtApi = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _buscar());
  }

  void _buscar() {
    context.read<AdminProvider>().fetchRelatorio(
          _fmtApi.format(_inicio),
          _fmtApi.format(_fim),
        );
  }

  Future<void> _selecionarPeriodo() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _inicio, end: _fim),
      builder: (context, child) => Theme(
        data: Theme.of(context)
            .copyWith(colorScheme: const ColorScheme.light(primary: Colors.deepOrange)),
        child: child!,
      ),
    );
    if (range != null) {
      setState(() {
        _inicio = range.start;
        _fim = range.end;
      });
      _buscar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatório Global'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            onRefresh: () async => _buscar(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Seletor de período
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.date_range, color: Colors.deepOrange),
                    title: Text(
                      '${_fmt.format(_inicio)} → ${_fmt.format(_fim)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Toque para alterar o período'),
                    onTap: _selecionarPeriodo,
                    trailing: const Icon(Icons.chevron_right),
                  ),
                ),
                const SizedBox(height: 16),
                if (provider.loading)
                  const Center(child: CircularProgressIndicator())
                else if (provider.error != null)
                  Center(child: Text(provider.error!))
                else if (provider.relatorio != null) ...[
                  // Cards de resumo
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Total de Vendas',
                          value: provider.relatorio!.totalVendas.toString(),
                          icon: Icons.receipt_long,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'Faturamento',
                          value:
                              'R\$ ${provider.relatorio!.faturamentoTotal}',
                          icon: Icons.attach_money,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(value,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
