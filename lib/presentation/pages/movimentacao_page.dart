import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inventory_app/models/produto_model.dart';
import '../../core/supa_helper.dart';
import '../../models/movimentacao_model.dart';
import '../../models/usuario_model.dart';
import '../../repositories/movimentacao_repository.dart';
import '../../repositories/produto_repository.dart';
import 'dashboard.dart';

class MovimentacaoPage extends StatefulWidget {
  final Usuario currentUser;
  final Produto produto;

  const MovimentacaoPage({
    super.key,
    required this.currentUser,
    required this.produto, // Adicione este parâmetro
  });

  @override
  State<MovimentacaoPage> createState() => _MovimentacaoPageState();
}

class _MovimentacaoPageState extends State<MovimentacaoPage> {
  final MovimentacaoRepository _repository = MovimentacaoRepository();
  List<Movimentacao> movimentacoes = [];
  bool isLoading = true;
  String tipoMovimentacao = 'saida'; // Default to saída
  final TextEditingController quantidadeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMovimentacoes();
  }

  Future<void> _loadMovimentacoes() async {
    try {
      final List<Movimentacao> userMovimentacoes;
      if (widget.currentUser.status == 'admin') {
        userMovimentacoes = await _repository.fetchAll();
      } else {
        userMovimentacoes =
            await _repository.fetchByUsuario(widget.currentUser.id_usuarios!);
      }

      setState(() {
        movimentacoes = userMovimentacoes;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading movimentações: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _registrarMovimentacao() async {
    if (quantidadeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira uma quantidade'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final quantidade = int.tryParse(quantidadeController.text);
    if (quantidade == null || quantidade <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira uma quantidade válida'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // First create the movement record
      final movimentacao = Movimentacao(
        id_produtos: widget.produto.id_produtos!,
        id_turma: widget.currentUser.turma,
        id_usuarios: widget.currentUser.id_usuarios!,
        data_saida: DateTime.now(),
        quantidade: quantidade,
        tipo: tipoMovimentacao,
        observacao: 'Registrado manualmente',
      );

      await _repository.insert(movimentacao);

      // Then update the product balance without creating another movement record
      final produtoRepository = ProdutoRepository();
      await produtoRepository.updateSaldo(
        widget.produto.id_produtos!,
        quantidade,
        tipoMovimentacao,
        userId: widget.currentUser.id_usuarios,
        skipMovementRecord: true, // This prevents duplicate records
      );

      quantidadeController.clear();
      await _loadMovimentacoes();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Movimentação registrada e saldo atualizado!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao registrar movimentação: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _clearAllMovimentacoes() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Movimentações'),
        content:
            const Text('Tem certeza que deseja limpar todas as movimentações?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Correção: Use 'movimentacao' em vez de 'movimentacoes'
        await SupabaseHelper.client
            .from('movimentacao') // Nome correto da tabela
            .delete()
            .neq('id_movimentacao', 0);

        await _loadMovimentacoes();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Todas as movimentações foram limpas'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao limpar movimentações: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[700]!, Colors.blue[500]!],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DashboardPage(
                              currentUser: widget.currentUser,
                            ),
                          ),
                        );
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'Movimentações',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (widget.currentUser.status == 'admin')
                      IconButton(
                        icon:
                            const Icon(Icons.delete_sweep, color: Colors.white),
                        onPressed: _clearAllMovimentacoes,
                        tooltip: 'Limpar todas as movimentações',
                      )
                    else
                      const SizedBox(width: 48),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nova Movimentação',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Entrada'),
                            value: 'entrada',
                            groupValue: tipoMovimentacao,
                            onChanged: (value) {
                              setState(() {
                                tipoMovimentacao = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Saída'),
                            value: 'saida',
                            groupValue: tipoMovimentacao,
                            onChanged: (value) {
                              setState(() {
                                tipoMovimentacao = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: quantidadeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Quantidade',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _registrarMovimentacao,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Registrar Movimentação'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : movimentacoes.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inbox_rounded,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Nenhuma movimentação encontrada',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: movimentacoes.length,
                              itemBuilder: (context, index) {
                                final movimentacao = movimentacoes[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          movimentacao.tipo == 'entrada'
                                              ? Colors.green.withOpacity(0.1)
                                              : Colors.red.withOpacity(0.1),
                                      child: Icon(
                                        movimentacao.tipo == 'entrada'
                                            ? Icons.add
                                            : Icons.remove,
                                        color: movimentacao.tipo == 'entrada'
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                    title: Text(
                                      'Movimentação #${movimentacao.id_movimentacao}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 8),
                                        Text(
                                          'Data: ${DateFormat('dd/MM/yyyy HH:mm').format(movimentacao.data_saida ?? DateTime.now())}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          'Quantidade: ${movimentacao.quantidade}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          'Tipo: ${movimentacao.tipo}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
