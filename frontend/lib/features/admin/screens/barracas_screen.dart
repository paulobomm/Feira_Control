import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';

class BarracasScreen extends StatefulWidget {
  const BarracasScreen({super.key});

  @override
  State<BarracasScreen> createState() => _BarracasScreenState();
}

class _BarracasScreenState extends State<BarracasScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<AdminProvider>();
      p.fetchBarracas();
      p.fetchFeirantes();
    });
  }

  void _showAddDialog() {
    final nomeCtrl = TextEditingController();
    final localCtrl = TextEditingController();
    String? selectedFeiranteId;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          final feirantes = context.read<AdminProvider>().feirantes;
          return AlertDialog(
            title: const Text('Nova Barraca'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nomeCtrl,
                    decoration: const InputDecoration(labelText: 'Nome'),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Informe o nome' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: localCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Localização'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedFeiranteId,
                    hint: const Text('Feirante (opcional)'),
                    items: feirantes
                        .map((f) => DropdownMenuItem(
                              value: f.id,
                              child: Text(f.nome),
                            ))
                        .toList(),
                    onChanged: (v) => setS(() => selectedFeiranteId = v),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar')),
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: Colors.deepOrange),
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  final ok = await context
                      .read<AdminProvider>()
                      .cadastrarBarraca(
                        nome: nomeCtrl.text.trim(),
                        localizacao: localCtrl.text.trim(),
                        feiranteId: selectedFeiranteId,
                      );
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Barraca cadastrada!')),
                    );
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barracas'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: Colors.deepOrange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nova', style: TextStyle(color: Colors.white)),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.barracas.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.store_mall_directory_outlined,
                      size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Nenhuma barraca cadastrada'),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.barracas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final b = provider.barracas[index];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE8F5E9),
                    child: Icon(Icons.store, color: Colors.green),
                  ),
                  title: Text(b.nome,
                      style:
                          const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: b.localizacao != null
                      ? Text(b.localizacao!)
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
