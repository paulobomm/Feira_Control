import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/feirante_provider.dart';

class EstoqueScreen extends StatefulWidget {
  const EstoqueScreen({super.key});

  @override
  State<EstoqueScreen> createState() => _EstoqueScreenState();
}

class _EstoqueScreenState extends State<EstoqueScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<FeiranteProvider>().fetchEstoque(),
    );
  }

  void _showAjusteDialog(String produtoId, String produtoNome, int atual) {
    final ctrl = TextEditingController(text: atual.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Ajustar Estoque\n$produtoNome',
            style: const TextStyle(fontSize: 16)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Nova quantidade',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          FilledButton(
            style:
                FilledButton.styleFrom(backgroundColor: Colors.deepOrange),
            onPressed: () async {
              final qty = int.tryParse(ctrl.text);
              if (qty == null || qty < 0) return;
              Navigator.pop(context);
              await context
                  .read<FeiranteProvider>()
                  .ajustarEstoque(produtoId, qty);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Estoque atualizado!')),
                );
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Color _statusColor(int qty) {
    if (qty <= 5) return Colors.red;
    if (qty <= 15) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estoque'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Consumer<FeiranteProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.estoque.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warehouse_outlined,
                      size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Nenhum item no estoque'),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => provider.fetchEstoque(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.estoque.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = provider.estoque[index];
                final color = _statusColor(item.quantidade);
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withOpacity(0.15),
                      child: Icon(Icons.warehouse, color: color),
                    ),
                    title: Text(item.produtoNome,
                        style:
                            const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      item.quantidade <= 5
                          ? 'Estoque baixo!'
                          : '${item.quantidade} unidades',
                      style: TextStyle(color: color),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${item.quantidade}',
                            style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => _showAjusteDialog(
                              item.produtoId,
                              item.produtoNome,
                              item.quantidade),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
