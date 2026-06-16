import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/feirante_provider.dart';

class ProdutosScreen extends StatefulWidget {
  const ProdutosScreen({super.key});

  @override
  State<ProdutosScreen> createState() => _ProdutosScreenState();
}

class _ProdutosScreenState extends State<ProdutosScreen> {
  final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<FeiranteProvider>().fetchProdutos(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Produtos'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/feirante/produtos/novo'),
        backgroundColor: Colors.deepOrange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Novo', style: TextStyle(color: Colors.white)),
      ),
      body: Consumer<FeiranteProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.produtos.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Nenhum produto cadastrado'),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.produtos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final p = provider.produtos[index];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE3F2FD),
                    child: Icon(Icons.inventory_2, color: Colors.blue),
                  ),
                  title: Text(p.nome,
                      style:
                          const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: p.descricao != null ? Text(p.descricao!) : null,
                  trailing: Text(
                    _currency.format(p.precoUnitario),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                        fontSize: 15),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
