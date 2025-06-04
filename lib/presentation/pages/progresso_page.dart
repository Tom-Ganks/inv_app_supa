import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/notificacoes_model.dart';
import '../../models/usuario_model.dart';
import '../../repositories/notificacao_repository.dart';
import '../../repositories/produto_repository.dart';
import 'dashboard.dart';

class ProgressoPage extends StatefulWidget {
  final Usuario currentUser;

  const ProgressoPage({
    super.key,
    required this.currentUser,
  });

  @override
  State<ProgressoPage> createState() => _ProgressoPageState();
}

class _ProgressoPageState extends State<ProgressoPage> {
  final NotificacoesRepository _repository = NotificacoesRepository();
  List<Notificacao> solicitacoes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSolicitacoes();
  }

  Future<void> _loadSolicitacoes() async {
    try {
      final List<Notificacao> userSolicitacoes;
      if (widget.currentUser.status == 'admin') {
        userSolicitacoes = await _repository.fetchAll();
      } else {
        userSolicitacoes =
            await _repository.fetchByUser(widget.currentUser.nome);
      }

      setState(() {
        solicitacoes = userSolicitacoes;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading solicitações: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _clearAllSolicitacoes() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Solicitações'),
        content:
            const Text('Tem certeza que deseja limpar todas as solicitações?'),
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
        await _repository.deleteAll();
        await _loadSolicitacoes();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Todas as solicitações foram limpas')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao limpar solicitações: $e')),
          );
        }
      }
    }
  }

  Future<void> _updateSolicitacaoStatus(Notificacao solicitacao) async {
    if (widget.currentUser.status != 'admin') return;

    final produto =
        await ProdutoRepository().fetchByName(solicitacao.produto_nome);
    if (produto == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto não encontrado')),
        );
      }
      return;
    }

    String selectedStatus = solicitacao.status;
    final quantidadeController = TextEditingController(
      text: solicitacao.quantidade_aprovada?.toString() ?? '',
    );
    final observacaoController = TextEditingController(
      text: solicitacao.observacao,
    );

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Atualizar Solicitação'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Produto: ${solicitacao.produto_nome}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Quantidade solicitada: ${solicitacao.quantidade}'),
                Text('Saldo disponível: ${produto.saldo}'),
                const SizedBox(height: 16),
                const Text('Status:'),
                RadioListTile<String>(
                  title: const Text('Aprovado'),
                  value: 'aprovado',
                  groupValue: selectedStatus,
                  onChanged: (value) {
                    setState(() => selectedStatus = value!);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Aprovado Parcialmente'),
                  value: 'parcial',
                  groupValue: selectedStatus,
                  onChanged: (value) {
                    setState(() => selectedStatus = value!);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Recusado'),
                  value: 'recusado',
                  groupValue: selectedStatus,
                  onChanged: (value) {
                    setState(() => selectedStatus = value!);
                  },
                ),
                if (selectedStatus == 'parcial') ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: quantidadeController,
                    decoration: const InputDecoration(
                      labelText: 'Quantidade aprovada',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: observacaoController,
                  decoration: const InputDecoration(
                    labelText: 'Observação',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final formData = {
                  'status': selectedStatus,
                  'quantidadeAprovada': selectedStatus == 'parcial'
                      ? int.tryParse(quantidadeController.text)
                      : null,
                  'observacao': observacaoController.text,
                };
                Navigator.pop(context, formData);
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      try {
        final int novaQuantidade = result['status'] == 'aprovado'
            ? solicitacao.quantidade
            : (result['quantidadeAprovada'] ?? 0);

        await _repository.updateStatus(
          solicitacao.id_notificacao!,
          status: result['status'],
          observacao: result['observacao'],
          quantidadeAprovada: novaQuantidade,
        );

        if (result['status'] == 'aprovado' || result['status'] == 'parcial') {
          final int novoSaldo = produto.saldo - novaQuantidade;
          await ProdutoRepository().updateSaldo(
            produto.id_produtos!,
            novoSaldo,
            'saida',
          );
        }

        await _loadSolicitacoes();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Solicitação atualizada com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e, stackTrace) {
        debugPrint('Erro ao atualizar: $e\n$stackTrace');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao atualizar solicitação: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
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
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
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
                        Expanded(
                          child: Text(
                            widget.currentUser.status == 'admin'
                                ? 'Gerenciar Solicitações'
                                : 'Minhas Solicitações',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (widget.currentUser.status == 'admin')
                          IconButton(
                            icon: const Icon(Icons.delete_sweep,
                                color: Colors.white),
                            onPressed: _clearAllSolicitacoes,
                            tooltip: 'Limpar todas as solicitações',
                          )
                        else
                          const SizedBox(width: 48),
                      ],
                    ),
                  ),
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
                          : solicitacoes.isEmpty
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
                                        'Nenhuma solicitação encontrada',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: _loadSolicitacoes,
                                  child: ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: solicitacoes.length,
                                    itemBuilder: (context, index) {
                                      final solicitacao = solicitacoes[index];
                                      return Card(
                                        margin:
                                            const EdgeInsets.only(bottom: 12),
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: InkWell(
                                          onTap: widget.currentUser.status ==
                                                  'admin'
                                              ? () => _updateSolicitacaoStatus(
                                                  solicitacao)
                                              : null,
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            solicitacao
                                                                .produto_nome,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          if (widget.currentUser
                                                                  .status ==
                                                              'admin')
                                                            Text(
                                                              'Solicitante: ${solicitacao.solicitante_nome}',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .grey[600],
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 12,
                                                        vertical: 6,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: solicitacao
                                                            .getStatusColor()
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      child: Text(
                                                        solicitacao
                                                            .getStatusDisplay(),
                                                        style: TextStyle(
                                                          color: solicitacao
                                                              .getStatusColor(),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Quantidade solicitada: ${solicitacao.quantidade}',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                if (solicitacao.status ==
                                                        'parcial' &&
                                                    solicitacao
                                                            .quantidade_aprovada !=
                                                        null)
                                                  Text(
                                                    'Quantidade aprovada: ${solicitacao.quantidade_aprovada}',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.orange[700],
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Data: ${DateFormat('dd/MM/yyyy HH:mm').format(solicitacao.data_solicitacao)}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[500],
                                                  ),
                                                ),
                                                if (solicitacao.observacao !=
                                                    null) ...[
                                                  const SizedBox(height: 8),
                                                  Container(
                                                    width: double.infinity,
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[100],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Observação:',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors
                                                                .grey[700],
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        Text(
                                                          solicitacao
                                                              .observacao!,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors
                                                                .grey[600],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
