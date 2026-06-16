import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';

class FeirantesScreen extends StatefulWidget {
  const FeirantesScreen({super.key});

  @override
  State<FeirantesScreen> createState() => _FeirantesScreenState();
}

class _FeirantesScreenState extends State<FeirantesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<AdminProvider>().fetchFeirantes(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feirantes'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/feirantes/novo'),
        backgroundColor: Colors.deepOrange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Novo', style: TextStyle(color: Colors.white)),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }
          if (provider.feirantes.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Nenhum feirante cadastrado'),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.feirantes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final f = provider.feirantes[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepOrange.shade100,
                    child: Text(
                      f.nome[0].toUpperCase(),
                      style: const TextStyle(
                          color: Colors.deepOrange, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(f.nome,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(f.email),
                  trailing: f.telefone != null
                      ? Text(f.telefone!,
                          style: const TextStyle(color: Colors.grey))
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
