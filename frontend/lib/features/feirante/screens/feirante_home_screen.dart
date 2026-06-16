import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';

class FeiranteHomeScreen extends StatelessWidget {
  const FeiranteHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FeiraControl'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Olá, ${user?.nome ?? ''}!',
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('O que deseja fazer hoje?',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _MenuCard(
                    icon: Icons.inventory_2,
                    label: 'Produtos',
                    color: Colors.blue,
                    onTap: () => context.push('/feirante/produtos'),
                  ),
                  _MenuCard(
                    icon: Icons.warehouse,
                    label: 'Estoque',
                    color: Colors.teal,
                    onTap: () => context.push('/feirante/estoque'),
                  ),
                  _MenuCard(
                    icon: Icons.point_of_sale,
                    label: 'Nova Venda',
                    color: Colors.deepOrange,
                    onTap: () => context.push('/feirante/vendas/nova'),
                  ),
                  _MenuCard(
                    icon: Icons.history,
                    label: 'Histórico',
                    color: Colors.purple,
                    onTap: () => context.push('/feirante/vendas'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 12),
            Text(label,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
