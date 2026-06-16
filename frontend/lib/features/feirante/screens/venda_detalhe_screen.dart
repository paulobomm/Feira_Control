import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/feirante_provider.dart';

class VendaDetalheScreen extends StatefulWidget {
  final String vendaId;

  const VendaDetalheScreen({super.key, required this.vendaId});

  @override
  State<VendaDetalheScreen> createState() => _VendaDetalheScreenState();
}

class _VendaDetalheScreenState extends State<VendaDetalheScreen> {
  final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final _dateFmt = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context
          .read<FeiranteProvider>()
          .fetchVendaDetalhe(widget.vendaId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhe da Venda'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Consumer<FeiranteProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          final venda = provider.vendaDetalhe;
          if (venda == null || venda.id != widget.vendaId) {
            return const Center(child: Text('Venda não encontrada'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Cabeçalho
              Card(
                color: Colors.deepOrange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(Icons.receipt_long,
                          size: 48, color: Colors.deepOrange),
                      const SizedBox(height: 12),
                      Text(
                        _currency.format(venda.total),
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange),
                      ),
                      const SizedBox(height: 4),
                      Text(_dateFmt.format(venda.createdAt),
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Itens da venda (${venda.itens.length})',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...venda.itens.map(
                (item) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.inventory_2,
                        color: Colors.blue),
                    title: Text(
                      item.produtoId,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 13),
                    ),
                    subtitle: Text(
                        '${item.quantidade}x ${_currency.format(item.precoUnitario)}'),
                    trailing: Text(
                      _currency.format(item.subtotal),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(
                        _currency.format(venda.total),
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
