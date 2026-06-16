import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/feirante_provider.dart';

class CreateProdutoScreen extends StatefulWidget {
  const CreateProdutoScreen({super.key});

  @override
  State<CreateProdutoScreen> createState() => _CreateProdutoScreenState();
}

class _CreateProdutoScreenState extends State<CreateProdutoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _precoCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _descCtrl.dispose();
    _precoCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final preco = double.tryParse(
        _precoCtrl.text.trim().replaceAll(',', '.'));

    final ok = await context.read<FeiranteProvider>().cadastrarProduto(
          nome: _nomeCtrl.text.trim(),
          descricao: _descCtrl.text.trim(),
          precoUnitario: preco!,
        );

    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produto cadastrado com sucesso!')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Produto'),
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
                  labelText: 'Nome do produto',
                  prefixIcon: Icon(Icons.inventory_2),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _precoCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Preço unitário (R\$)',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe o preço';
                  final val = double.tryParse(v.replaceAll(',', '.'));
                  if (val == null || val <= 0) return 'Preço inválido';
                  return null;
                },
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
