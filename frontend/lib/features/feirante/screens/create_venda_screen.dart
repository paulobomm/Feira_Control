import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/feirante_models.dart';
import '../providers/feirante_provider.dart';

class _ItemCarrinho {
  final Produto produto;
  int quantidade;

  _ItemCarrinho({required this.produto, this.quantidade = 1});

  double get subtotal => produto.precoUnitario * quantidade;
}

class CreateVendaScreen extends StatefulWidget {
  const CreateVendaScreen({super.key});

  @override
  State<CreateVendaScreen> createState() => _CreateVendaScreenState();
}

class _CreateVendaScreenState extends State<CreateVendaScreen> {
  final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final List<_ItemCarrinho> _carrinho = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<FeiranteProvider>().fetchProdutos(),
    );
  }

  void _adicionarProduto(Produto produto) {
    setState(() {
      final existing = _carrinho.where((i) => i.produto.id == produto.id);
      if (existing.isNotEmpty) {
        existing.first.quantidade++;
      } else {
        _carrinho.add(_ItemCarrinho(produto: produto));
      }
    });
  }

  void _removerItem(int index) => setState(() => _carrinho.removeAt(index));

  double get _total =>
      _carrinho.fold(0, (acc, item) => acc + item.subtotal);

  Future<void> _confirmarVenda() async {
    if (_carrinho.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione ao menos um produto')),
      );
      return;
    }

    setState(() => _loading = true);

    final itens = _carrinho
        .map((i) => {'produtoId': i.produto.id, 'quantidade': i.quantidade})
        .toList();

    final ok = await context.read<FeiranteProvider>().registrarVenda(itens);

    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Venda registrada! Total: ${_currency.format(_total)}')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Venda'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Consumer<FeiranteProvider>(
        builder: (context, provider, _) {
          if (provider.loading && provider.produtos.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              // Lista de produtos para adicionar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Produtos disponíveis',
                    style: Theme.of(context).textTheme.titleSmall),
              ),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.produtos.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final p = provider.produtos[index];
                    return GestureDetector(
                      onTap: () => _adicionarProduto(p),
                      child: Card(
                        color: Colors.deepOrange.shade50,
                        child: SizedBox(
                          width: 110,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_circle,
                                    color: Colors.deepOrange),
                                const SizedBox(height: 4),
                                Text(p.nome,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text(_currency.format(p.precoUnitario),
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.deepOrange)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              // Carrinho
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Text('Carrinho (${_carrinho.length} itens)',
                        style:
                            Theme.of(context).textTheme.titleSmall),
                  ],
                ),
              ),
              Expanded(
                child: _carrinho.isEmpty
                    ? const Center(
                        child: Text('Adicione produtos tocando neles acima',
                            style: TextStyle(color: Colors.grey)))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: _carrinho.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = _carrinho[index];
                          return Card(
                            child: ListTile(
                              title: Text(item.produto.nome),
                              subtitle: Text(
                                  _currency.format(item.produto.precoUnitario)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle,
                                        color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        if (item.quantidade > 1) {
                                          item.quantidade--;
                                        } else {
                                          _removerItem(index);
                                        }
                                      });
                                    },
                                  ),
                                  Text('${item.quantidade}',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle,
                                        color: Colors.green),
                                    onPressed: () => setState(
                                        () => item.quantidade++),
                                  ),
                                  SizedBox(
                                    width: 70,
                                    child: Text(
                                      _currency.format(item.subtotal),
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepOrange),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              // Total + botão
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, -2))
                  ],
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Total',
                            style: TextStyle(color: Colors.grey)),
                        Text(_currency.format(_total),
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange)),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: FilledButton.icon(
                          onPressed: _loading ? null : _confirmarVenda,
                          style: FilledButton.styleFrom(
                              backgroundColor: Colors.deepOrange),
                          icon: _loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.check),
                          label: const Text('Confirmar Venda'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
