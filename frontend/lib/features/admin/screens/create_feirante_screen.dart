import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';

class CreateFeiranteScreen extends StatefulWidget {
  const CreateFeiranteScreen({super.key});

  @override
  State<CreateFeiranteScreen> createState() => _CreateFeiranteScreenState();
}

class _CreateFeiranteScreenState extends State<CreateFeiranteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telefoneCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _telefoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final ok = await context.read<AdminProvider>().cadastrarFeirante(
          nome: _nomeCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          telefone: _telefoneCtrl.text.trim(),
        );

    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feirante cadastrado com sucesso!')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Feirante'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nome completo',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || !v.contains('@')) ? 'E-mail inválido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefone (opcional)',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _loading ? null : _salvar,
                  style: FilledButton.styleFrom(
                      backgroundColor: Colors.deepOrange),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Salvar', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
